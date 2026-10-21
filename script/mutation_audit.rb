#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "optparse"
require "rbconfig"
require "securerandom"
require_relative "../lib/test_database_url"

# Run a declared audit queue serially against the checkout's isolated test DB.
# Measurement and behavioral review are separate states: a complete matrix never
# authorizes deletion or marks a behavioral review complete. Content signatures
# prevent a resumed sweep from reusing results after code, fixtures, or tests
# change, including changes made while a mutant run is still in progress.
class MutationAudit
  ROOT = File.expand_path("..", __dir__)
  PLAN = File.join(ROOT, "agents/mutation_audit_plan.json")
  PROGRESS = File.join(ROOT, "agents/mutation_audit_progress.json")
  REVIEWS = File.join(ROOT, "agents/mutation_audit_reviews.json")
  REPORT_ROOT = File.join(ROOT, "tmp/mutation_audit")

  def initialize(options)
    @options = options
    @plan = JSON.parse(File.read(PLAN))
    missing = @plan.fetch("units").flat_map do |unit|
      (unit.fetch("sources") + unit.fetch("tests") + unit.fetch("requires", [])).filter_map do |file|
        "#{unit.fetch('id')}: #{file}" unless File.file?(File.join(ROOT, file))
      end
    end
    raise "Audit plan references missing inputs:\n#{missing.join("\n")}" unless missing.empty?
    selected_ids = Array(options[:only_ids]) + Array(options[:exclude_ids])
    unknown_ids = selected_ids.uniq - @plan.fetch("units").map { |unit| unit.fetch("id") }
    raise ArgumentError, "Unknown audit contexts: #{unknown_ids.join(', ')}" unless unknown_ids.empty?

    @progress = if File.exist?(PROGRESS)
      JSON.parse(File.read(PROGRESS))
    else
      { "schema_version" => 1, "units" => {} }
    end
  end

  def status
    signatures = if File.file?(@options.fetch(:tool))
      @plan.fetch("units").to_h { |unit| [unit.fetch("id"), signature(unit)] }
    end
    counts = @plan.fetch("units").group_by do |unit|
      record = @progress.fetch("units")[unit.fetch("id")]
      if unit.fetch("measurement") != "pending"
        unit.fetch("measurement")
      elsif record && signatures && record.fetch("signature") != signatures.fetch(unit.fetch("id"))
        "stale"
      elsif record && %w[measured unexercised].include?(record.fetch("measurement")) &&
            !File.file?(File.join(ROOT, record.fetch("report")))
        "report_missing"
      else
        record ? record.fetch("measurement") : unit.fetch("measurement")
      end
    end.transform_values(&:size)
    reviews = File.exist?(REVIEWS) ? JSON.parse(File.read(REVIEWS)).fetch("units") : {}
    completed = reviews.count do |id, review|
      record = @progress.fetch("units")[id]
      review.fetch("review") == "complete" && record && record.fetch("signature") == review.fetch("signature") &&
        (!signatures || signatures[id] == review.fetch("signature"))
    end
    planned_tests = @plan.fetch("units").flat_map { |unit| unit.fetch("tests") }
    structural_reviews = @plan.fetch("units").count do |unit|
      id = unit.fetch("id")
      unit.fetch("measurement") == "structural_review" && reviews.dig(id, "review") == "complete" &&
        (!signatures || signatures[id] == reviews.dig(id, "signature"))
    end
    required_tests = Dir.glob(File.join(ROOT, "test/{models,controllers,services}/**/*_test.rb"))
                        .map { |file| file.delete_prefix("#{ROOT}/") }
    puts JSON.generate(units: @plan.fetch("units").size, measurements: counts, reviews_complete: completed,
                       structural_reviews_recorded: structural_reviews,
                       unplanned_tests: required_tests - planned_tests,
                       note: signatures ? "Content signatures revalidated." : "Recorded measurements; provide --tool to revalidate content signatures.")
  end

  def run
    raise "Missing Mutineer executable: #{@options.fetch(:tool)}" unless File.file?(@options.fetch(:tool))
    FileUtils.mkdir_p(REPORT_ROOT)
    attempts = 0
    File.open(File.join(REPORT_ROOT, "run.lock"), "w") do |lock|
      raise "A mutation audit is already running in this checkout" unless lock.flock(File::LOCK_EX | File::LOCK_NB)

      selected = @plan.fetch("units").select { |unit| unit.fetch("measurement") == "pending" }
      selected.select! { |unit| unit.fetch("id").include?(@options[:only]) } if @options[:only]
      selected.select! { |unit| @options[:only_ids].include?(unit.fetch("id")) } if @options[:only_ids]
      selected.reject! { |unit| Array(@options[:exclude_ids]).include?(unit.fetch("id")) }
      if partition = @options[:partition]
        index, count = partition
        selected.select! { |unit| Digest::SHA256.hexdigest(unit.fetch("id")).to_i(16) % count == index }
      end
      selected.sort_by! { |unit| [unit.fetch("candidate_count"), unit.fetch("id")] }
      previous_handler = Signal.trap("USR1") { @stop_requested = true }
      begin
        selected.each do |unit|
          break if @stop_requested || (@options[:limit] && attempts >= @options[:limit])

          attempts += 1 if measure(unit)
        end
      ensure
        Signal.trap("USR1", previous_handler)
      end
    end
    status
    attempts
  end

  # Import evidence from isolated checkout partitions only while this
  # checkout's runner is stopped. Revalidate against the current local inputs;
  # a worker's earlier snapshot cannot establish coverage of later test edits.
  def merge
    FileUtils.mkdir_p(REPORT_ROOT)
    File.open(File.join(REPORT_ROOT, "run.lock"), "w") do |lock|
      raise "Stop this checkout's audit before merging partition results" unless lock.flock(File::LOCK_EX | File::LOCK_NB)

      units = @plan.fetch("units").to_h { |unit| [unit.fetch("id"), unit] }
      imported = []
      @options.fetch(:from).each do |checkout|
        incoming = JSON.parse(File.read(File.join(checkout, "agents/mutation_audit_progress.json")))
        incoming.fetch("units").each do |id, record|
          next unless %w[measured unexercised incomplete].include?(record.fetch("measurement"))

          # Grouped contexts retain their historical evidence in the originating
          # checkout, but are no longer independent experiments in this plan.
          next unless unit = units[id]
          next unless unit.fetch("measurement") == "pending"
          next unless record.fetch("signature") == signature(unit)
          next unless File.file?(File.join(checkout, record.fetch("report")))

          previous = @progress.fetch("units")[id]
          next if record.fetch("measurement") == "incomplete" && previous &&
                  previous["signature"] == record.fetch("signature") &&
                  %w[measured unexercised].include?(previous["measurement"])
          next if previous && previous["signature"] == record.fetch("signature") &&
                  previous["measurement"] == record.fetch("measurement") &&
                  File.file?(File.join(ROOT, previous.fetch("report")))

          source = File.dirname(File.join(checkout, record.fetch("report")))
          destination = File.dirname(File.join(ROOT, record.fetch("report")))
          FileUtils.mkdir_p(destination)
          Dir.children(source).each do |name|
            file = File.join(source, name)
            FileUtils.cp(file, File.join(destination, name)) if File.file?(file)
          end
          @progress.fetch("units")[id] = record.merge("execution_checkout" => record.fetch("execution_checkout", checkout))
          imported << id
        end
      end
      save
      puts JSON.generate(imported: imported)
    end
    status
  end

  private

  # Include shared application and fixture inputs, not just the mutated file:
  # another component can change whether a supposedly redundant test matters.
  def signature(unit)
    dependencies = Array(unit["covered_by"]).map do |id|
      @plan.fetch("units").find { |candidate| candidate.fetch("id") == id } ||
        raise(ArgumentError, "Unknown dependency #{id} for #{unit.fetch('id')}")
    end
    files = Dir.glob(File.join(ROOT, "{app,lib,config}/**/*.rb")) +
      Dir.glob(File.join(ROOT, "test/{fixtures,support}/**/*")).select { |file| File.file?(file) } +
      %w[Gemfile.lock db/schema.rb test/test_helper.rb test/reset_database_helper.rb].map { |file| File.join(ROOT, file) } +
      (unit.fetch("sources") + unit.fetch("tests") + unit.fetch("requires", [])).map { |file| File.join(ROOT, file) }
    dependencies.each do |dependency|
      files.concat((dependency.fetch("sources") + dependency.fetch("tests") + dependency.fetch("requires", [])).map { |file| File.join(ROOT, file) })
    end
    digest = Digest::SHA256.new
    digest << RUBY_DESCRIPTION
    tool_version = File.expand_path("../lib/mutineer/version.rb", File.dirname(@options.fetch(:tool)))
    digest << JSON.generate(@plan.fetch("operators")) << JSON.generate(unit.slice("sources", "tests", "requires", "timeout", "capture_timeout"))
    if dependencies.any?
      digest << JSON.generate(dependencies.map { |dependency| dependency.slice("id", "sources", "tests", "requires", "timeout", "capture_timeout") })
    end
    digest << File.read(@options.fetch(:tool)) << File.read(tool_version)
    files.uniq.sort.each { |file| digest << file.delete_prefix(ROOT) << File.binread(file) }
    digest.hexdigest
  end

  # Establish a green baseline, capture the full matrix, then accept only a
  # complete result for unchanged inputs. Keep failed and partial evidence so
  # a resumed audit cannot mistake interruption or timeout for preserved kills.
  def measure(unit)
    id = unit.fetch("id")
    before_signature = signature(unit)
    existing = @progress.fetch("units")[id]
    if existing && existing["signature"] == before_signature && %w[measured unexercised].include?(existing["measurement"]) &&
       File.file?(File.join(ROOT, existing.fetch("report")))
      puts JSON.generate(unit: id, measurement: "reused")
      return false
    end

    # A retry keeps earlier partial reports and logs intact, including when
    # another isolated checkout later imports this attempt's evidence.
    report_dir = File.join(REPORT_ROOT, id, "#{before_signature}-#{SecureRandom.uuid}")
    FileUtils.mkdir_p(report_dir)
    report_file = File.join(report_dir, "before.json")
    log_file = File.join(report_dir, "before.log")
    command = [RbConfig.ruby, @options.fetch(:tool), "run", *unit.fetch("sources")]
    unless unit.fetch("requires", []).empty?
      boot_file = File.join(report_dir, "boot.rb")
      boot_sources = ["config/environment.rb", *unit.fetch("requires")]
      File.write(boot_file, boot_sources.map { |file| "require #{File.join(ROOT, file).inspect}\n" }.join)
      command.concat(["--boot", boot_file])
    end
    unit.fetch("tests").each { |file| command.concat(["--test", file]) }
    command.concat(["--rails", "--jobs", "1", "--matrix", "--timeout", unit.fetch("timeout", 30).to_s,
                    "--capture-timeout", unit.fetch("capture_timeout", 180).to_s,
                    "--operators", @plan.fetch("operators").join(","),
                    "--cache-dir", File.join(report_dir, "cache"), "--format", "json", "--output", report_file])
    environment = { "RAILS_ENV" => "test", "DATABASE_URL" => TestDatabaseUrl.resolve(root: ROOT) }
    environment["PGGSSENCMODE"] = "disable" if RUBY_PLATFORM.include?("darwin")
    record = {
      "measurement" => "running", "review" => "pending", "signature" => before_signature,
      "execution_checkout" => ROOT,
      "sources" => unit.fetch("sources"), "tests" => unit.fetch("tests"),
      "report" => report_file.delete_prefix("#{ROOT}/"), "log" => log_file.delete_prefix("#{ROOT}/")
    }
    @progress.fetch("units")[id] = record
    save
    puts JSON.generate(unit: id, measurement: "running", candidates: unit.fetch("candidate_count"))

    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    baseline_file = File.join(report_dir, "baseline.log")
    record["baseline_log"] = baseline_file.delete_prefix("#{ROOT}/")
    File.open(baseline_file, "w") do |log|
      @child = Process.spawn(environment, RbConfig.ruby, "bin/rails", "test", *unit.fetch("tests"),
                             chdir: ROOT, out: log, err: log, pgroup: true)
      _pid, process_status = Process.wait2(@child)
      @child = nil
      record["baseline_exit_code"] = process_status.exitstatus
    end
    unless record.fetch("baseline_exit_code") == 0
      record["measurement"] = "baseline_failed"
      save
      puts JSON.generate(unit: id, measurement: "baseline_failed", log: record.fetch("baseline_log"))
      return true
    end

    File.open(log_file, "w") do |log|
      @child = Process.spawn(environment, *command, chdir: ROOT, out: log, err: log, pgroup: true)
      _pid, process_status = Process.wait2(@child)
      @child = nil
      record["exit_code"] = process_status.exitstatus
    end
    record["seconds"] = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started).round(2)
    record["measurement"] = "failed"
    if File.exist?(report_file)
      report = JSON.parse(File.read(report_file))
      record["summary"] = report.fetch("summary")
      matrix = report.fetch("matrix")
      record["matrix_complete"] = matrix.fetch("complete")
      record["tests_observed"] = matrix.fetch("tests").size
      record["blind_candidates"] = matrix.fetch("blind").size
      record["redundant_candidates"] = matrix.fetch("redundant").size
      record["measurement"] = if record.fetch("summary").fetch("attempted").zero?
        "unexercised"
      elsif !matrix.fetch("complete") || record.fetch("summary").fetch("no_verdict").positive? ||
            record.fetch("summary").fetch("timeout").positive?
        "incomplete"
      elsif [0, 1].include?(record.fetch("exit_code")) && record.fetch("summary").fetch("errored").zero?
        "measured"
      else
        "failed"
      end
    end
    record["measurement"] = "stale" unless signature(unit) == before_signature
    save
    puts JSON.generate(unit: id, **record.slice("measurement", "seconds", "summary", "tests_observed",
                                               "blind_candidates", "redundant_candidates"))
    true
  rescue Interrupt
    stop_child
    record["measurement"] = "interrupted" if record
    save
    raise
  rescue JSON::ParserError, KeyError => error
    raise unless record

    record["measurement"] = "failed"
    record["error"] = "#{error.class}: #{error.message}"
    save
    puts JSON.generate(unit: id, measurement: "failed", error: record.fetch("error"))
    true
  end

  # Forked test workers can outlive the CLI leader after INT. Drain the whole
  # group before another run resets fixtures in the same isolated database.
  def stop_child
    return unless @child

    begin
      Process.kill("INT", -@child)
    rescue Errno::ESRCH
      # The leader and its workers already exited.
    end
    begin
      Process.wait(@child)
    rescue Errno::ECHILD
      # The signal arrived after the leader was reaped.
    end
    begin
      Process.kill("TERM", -@child)
    rescue Errno::ESRCH
      # No forked workers remain in the group.
    end
    @child = nil
  end

  def save
    # Review notes may be added while another unit is being measured. Preserve
    # them only when they describe the same content signature as this result.
    if File.exist?(PROGRESS)
      persisted = JSON.parse(File.read(PROGRESS)).fetch("units")
      @progress.fetch("units").each do |id, record|
        previous = persisted[id]
        next unless previous && previous["signature"] == record["signature"]

        record.merge!(previous.slice("review", "decision", "reviewed_sources", "review_notes", "verification"))
      end
    end
    temporary = "#{PROGRESS}.tmp"
    File.write(temporary, JSON.pretty_generate(@progress) + "\n")
    File.rename(temporary, PROGRESS)
  end
end

if $PROGRAM_NAME == __FILE__
  $stdout.sync = true
  options = { tool: File.join(MutationAudit::ROOT, "tmp/mutineer/gems/gems/mutineer-1.6.0/bin/mutineer") }
  command = ARGV.shift
  OptionParser.new do |parser|
    parser.banner = "Usage: ruby script/mutation_audit.rb status|run|merge [--tool FILE] [--only TEXT] [--only-id ID] [--exclude-id ID] [--limit N] [--partition INDEX/COUNT] [--from CHECKOUT]"
    parser.on("--tool FILE") { |value| options[:tool] = File.expand_path(value) }
    parser.on("--only TEXT") { |value| options[:only] = value }
    parser.on("--only-id ID") { |value| (options[:only_ids] ||= []) << value }
    parser.on("--exclude-id ID") { |value| (options[:exclude_ids] ||= []) << value }
    parser.on("--limit N", Integer) { |value| options[:limit] = value }
    parser.on("--from CHECKOUT") { |value| (options[:from] ||= []) << File.expand_path(value) }
    parser.on("--partition INDEX/COUNT") do |value|
      raise ArgumentError, "Expected zero-based INDEX/COUNT" unless value.match?(/\A\d+\/\d+\z/)

      index, count = value.split("/").map(&:to_i)
      raise ArgumentError, "Partition index must be less than a positive count" unless count.positive? && index < count

      options[:partition] = [index, count]
    end
  end.parse!
  raise ArgumentError, "Expected status, run, or merge" unless %w[status run merge].include?(command)
  raise ArgumentError, "merge requires --from CHECKOUT" if command == "merge" && !options[:from]
  raise ArgumentError, "--limit must be positive" if options[:limit] && options[:limit] <= 0

  MutationAudit.new(options).public_send(command)
end
