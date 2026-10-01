namespace :loomio do
  class Hash
    def bury *args
      if args.count < 2
        raise ArgumentError.new("2 or more arguments required")
      elsif args.count == 2
        self[args[0]] = args[1]
      else
        arg = args.shift
        self[arg] = {} unless self[arg]
        self[arg].bury(*args) unless args.empty?
      end
      self
    end
  end

  def list_paths(hash, prefixes)
    paths = []
    hash.keys.each do |key|
      if hash[key].is_a? Hash
        paths.concat list_paths(hash[key], prefixes + Array(key))
      else
        paths.push (prefixes + Array(key)).join('.')
      end
    end
    paths
  end

  # Flattens a locale file's nested strings to {"a.b.c" => string}.
  def flatten_strings(hash, prefix = nil, output = {})
    hash.each do |key, value|
      path = prefix ? "#{prefix}.#{key}" : key.to_s
      value.is_a?(Hash) ? flatten_strings(value, path, output) : output[path] = value
    end
    output
  end

  def translation_locales
    ENV["LOCALES"].present? ? ENV["LOCALES"].split(",") : AppConfig.locales["supported"] - ["en"]
  end

  # Runs the codex translator over each locale's client and server strings, in
  # parallel across locales. The block picks the strings to translate from the
  # English and the locale's current strings, returning them as
  # {key => English}, and current translations to revise as {key => text}.
  # Keys are "client.…" or "server.…". Each file is saved after every batch.
  def translate_app_strings(locales)
    english = %w[client server].each_with_object({}) do |kind, strings|
      flatten_strings(YAML.load_file("config/locales/#{kind}.en.yml")["en"], kind, strings)
    end
    output_mutex = Mutex.new
    failures = Queue.new

    locales.map do |locale|
      Thread.new do
        files = %w[client server].to_h do |kind|
          filename = "config/locales/#{kind}.#{locale}.yml"
          [kind, File.exist?(filename) ? YAML.load_file(filename).fetch(locale, {}) : {}]
        end
        current = files.each_with_object({}) { |(kind, strings), output| flatten_strings(strings, kind, output) }
        strings, revise = yield(locale, english, current)
        next if strings.empty?

        output_mutex.synchronize { puts "#{locale}: translating #{strings.size} strings" }
        translator = AppStringTranslator.new(locale, existing: current)
        result = translator.translate(strings, current: revise) do |batch|
          batch.each do |key, translation|
            kind, *path = key.split(".")
            files.fetch(kind).bury(*path, translation)
          end
          batch.keys.map { |key| key.split(".").first }.uniq.each do |kind|
            File.write("config/locales/#{kind}.#{locale}.yml", { locale => files.fetch(kind) }.to_yaml(line_width: 2000))
          end
        end
        result.failures.each { |key, message| failures << "#{locale}: #{key}: #{message}" }
      rescue => error
        failures << "#{locale}: #{error.class}: #{error.message}"
      end
    end.each(&:join)

    raise "Translation failed for #{failures.size} string(s):\n#{Array.new(failures.size) { failures.pop }.join("\n")}" unless failures.empty?
  end

  # Strings whose translation breaks the glossary: a rendering it marks as
  # wrong, or (with missing: true) no preferred term where the English uses one.
  def glossary_problems(locale, english, current, missing:)
    current.each_with_object({}) do |(key, translation), problems|
      source = english[key]
      next unless source.is_a?(String) && translation.is_a?(String) && translation.present?

      messages = TranslationGlossary.wrong_terms(source, translation, locale)
      messages += TranslationGlossary.missing_terms(source, translation, locale) if missing
      problems[key] = messages if messages.any?
    end
  end

  def delete_keys(hash, keys)
    # Dotted keys are exact paths; undotted keys match any key (leaf or subtree) whose last segment equals the key.
    exact_paths = keys.select { |k| k.include?('.') }
    leaf_names  = keys - exact_paths

    # Helper to delete at an exact dotted path and prune empty hashes along the way.
    delete_exact = lambda do |h, parts|
      return if parts.empty? || !h.is_a?(Hash)
      key = parts.first
      if parts.length == 1
        h.delete(key)
      else
        child = h[key]
        if child.is_a?(Hash)
          delete_exact.call(child, parts[1..-1])
          h.delete(key) if child.empty?
        end
      end
    end

    # Delete exact dotted paths first.
    exact_paths.each do |path|
      delete_exact.call(hash, path.split('.'))
    end

    # Recursively delete any key (leaf or subtree) whose last segment matches an undotted key, and prune empties.
    if leaf_names.any?
      hash.keys.each do |k|
        v = hash[k]
        if leaf_names.include?(k)
          hash.delete(k)
        elsif v.is_a?(Hash)
          delete_keys(v, leaf_names)
          hash.delete(k) if v.empty?
        end
      end
    end
  end

  task generate_test_error: :environment do
    raise "this is a generated test error"
  end

  task :version do
    puts Version.current
  end

  desc "Audit missing inline image attachments, or queue repair when APPLY_INLINE_IMAGE_REPAIR is present"
  task repair_inline_image_attachments: :environment do
    if ENV.key?("APPLY_INLINE_IMAGE_REPAIR")
      RepairInlineImageAttachmentsWorker.perform_later
      puts "Queued inline image attachment repair"
    else
      stats = InlineImageAttachmentRepairService.run(
        dry_run: true,
        progress: ->(message) { puts message }
      )
      puts "DRY RUN: #{stats.to_json}"
      puts "Set APPLY_INLINE_IMAGE_REPAIR to queue the repair job"
    end
  end

  task check_translations: :environment do
    %w[server client].each do |source_name|
      source = YAML.load_file("config/locales/#{source_name}.en.yml")['en']
      source_paths = list_paths(source, [])

      AppConfig.locales['supported'].each do |locale|
        foreign = YAML.load_file("config/locales/#{source_name}.#{locale}.yml")[locale]
        foreign_paths = list_paths(foreign, [])

        source_paths.each do |path|
          # puts "#{locale}: #{path}, #{source.dig(*path.split('.'))}"
          source_string = (source.dig(*path.split('.')) || "").strip
          foreign_string = (foreign.dig(*path.split('.')) || "").strip
          next if foreign_string.blank?
          source_string.scan(/\%\{\w+\}/).each do |name|
            unless foreign_string.include?(name)
              puts "#{source_name}.#{locale}.yml #{path} missing #{name} in #{foreign_string}"
            end
          end
        end
      end
    end
  end

  task check_placeholder_consistency: :environment do
    %w[server client].each do |source_name|
      source = YAML.load_file("config/locales/#{source_name}.en.yml")['en']
      source_paths = list_paths(source, [])

      AppConfig.locales['supported'].each do |locale|
        foreign = YAML.load_file("config/locales/#{source_name}.#{locale}.yml")[locale]

        source_paths.each do |path|
          source_string  = (source.dig(*path.split('.')) || "").to_s.strip
          foreign_string = (foreign.dig(*path.split('.')) || "").to_s.strip
          next if foreign_string.blank?

          src_names = source_string.scan(/\%\{([a-zA-Z0-9_]+)\}/).flatten.sort.uniq
          fr_names  = foreign_string.scan(/\%\{([a-zA-Z0-9_]+)\}/).flatten.sort.uniq

          if src_names != fr_names
            puts "config/locales/#{source_name}.#{locale}.yml #{path}"
          end
        end
      end
    end
  end

  task delete_translations: :environment do
    # edit tmp/delete_translations.txt with one dotted key path per line
    unwanted = File.readlines("tmp/delete_translations.txt").map(&:strip).reject(&:empty?)

    %w[client server].each do |source_name|
      AppConfig.locales['supported'].each do |locale|
        next if locale == 'en'
        foreign = YAML.load_file("config/locales/#{source_name}.#{locale}.yml")[locale]
        delete_keys(foreign, unwanted)
        File.write("config/locales/#{source_name}.#{locale}.yml", {locale => foreign}.to_yaml(line_width: 2000))
      end
    end
  end

  desc "Translate English app strings missing from each locale with codex and the glossary (optional LOCALES=fr,de)"
  task translate_strings: :environment do
    translate_app_strings(translation_locales) do |_locale, english, current|
      [english.reject { |key, value| current.key?(key) || value.to_s.strip.empty? }, {}]
    end
  end

  desc "Report app strings that break config/locales/glossary.yml to tmp/glossary/<locale>.csv (optional LOCALES)"
  task check_glossary: :environment do
    english = %w[client server].each_with_object({}) do |kind, strings|
      flatten_strings(YAML.load_file("config/locales/#{kind}.en.yml")["en"], kind, strings)
    end
    FileUtils.mkdir_p("tmp/glossary")
    translation_locales.each do |locale|
      current = %w[client server].each_with_object({}) do |kind, strings|
        flatten_strings(YAML.load_file("config/locales/#{kind}.#{locale}.yml").fetch(locale, {}), kind, strings)
      end
      problems = glossary_problems(locale, english, current, missing: true)
      CSV.open("tmp/glossary/#{locale}.csv", "w") do |csv|
        csv << %w[key english translation problems]
        problems.each { |key, messages| csv << [key, english[key], current[key], messages.join("; ")] }
      end
      wrong = problems.count { |_, messages| messages.any? { |message| message.include?(" instead of ") } }
      puts "#{locale}: #{wrong} wrong terms, #{problems.size - wrong} missing terms"
    end
  end

  desc "Revise app strings that break the glossary with codex (optional LOCALES; MISSING to also revise strings missing a preferred term)"
  task apply_glossary: :environment do
    translate_app_strings(translation_locales) do |locale, english, current|
      problems = glossary_problems(locale, english, current, missing: ENV["MISSING"].present?)
      [english.slice(*problems.keys), current.slice(*problems.keys)]
    end
  end

  task generate_email_icons: :environment do
    colors = AppConfig.colors.flatten.flatten.filter {|c| c.starts_with?("#")}.map {|c| c[1..-1]}
    source_path = Rails.root.join("app", "assets", "images", "icons", "svgs", "*.svg").to_s
    dest_path = Rails.root.join("app", "assets", "images", "icons")

    Dir[source_path].each do |path|
      original = File.read(path)
      basename = File.basename(path).split(".").first
      document = Nokogiri::XML.parse(original)
      Dir.chdir(dest_path) do
        colors.each do |color|
          current = document.dup
          # current.css('svg').first.set_attribute 'viewBox', "0 0 96 96"
          current.css("path:not([fill])").set(:fill, "##{color}")
          im = Vips::Image.new_from_buffer(current.to_s, "", {scale: 8})
          im.write_to_file dest_path.to_s+"/#{basename}-#{color}.png"
        end
      end
    end
  end

  task generate_static_error_pages: :environment do
    [400, 404, 403, 410, 417, 422, 429, 500].each do |code|
      ['html'].each do |format|
        component = Views::Application::Error.new(
          title: I18n.t("errors.#{code}.title"),
          body: I18n.t("errors.#{code}.body")
        )
        output = ApplicationController.renderer.render(component, layout: false)

        File.open("public/#{code}.#{format}", "w") do |f|
          if format == "html"
            f << "<!-- This file is automatically generated by rake loomio:generate_static_error_pages -->\n"
            f << "<!-- Don't make changes here; they will be overwritten. -->\n"
          end
          f << output
        end
      end
    end
  end

  task :hourly_tasks do
  end

  task solid_queue_hourly_tasks: :environment do
    HourlyTaskJob.perform_now
  end

  task generate_error: :environment do
    raise "this is an exception to test exception handling"
  end

  task publish_system_notice: :environment do
    MessageChannelService.publish_system_notice(ENV['LOOMIO_SYSTEM_NOTICE'])
  end

  task update_subscription_members_counts: :environment do
    SubscriptionService.update_member_counts
  end

  task refresh_expiring_chargify_management_links: :environment do
    # run this once a week
    if Date.today.sunday?
      GenericWorker.perform_later('SubscriptionService', 'refresh_expiring_management_links')
    end
  end

  task populate_chargify_management_links: :environment do
    if Date.today.sunday?
      GenericWorker.perform_later('SubscriptionService', 'populate_management_links')
    end
  end

  task rebuild_search_index: :environment do
    GenericWorker.perform_later('SearchService', 'reindex_everything')
    puts "SearchService.reindex_everything queued as background job"
  end

  desc "Report untouched legacy seeded discussions and polls eligible for deletion"
  task audit_unused_seeded_content: :environment do
    SeededContentCleanupService.audit
  end

  desc "Count topic-free free groups and expired trials older than 60 days (optional LIMIT)"
  task audit_empty_groups: :environment do
    limit = ENV["LIMIT"].presence&.to_i
    plan_counts = CleanupService::EMPTY_GROUP_SUBSCRIPTION_PLANS.index_with do |plan|
      {
        empty_roots: CleanupService.audit_empty_groups(plan: plan, limit: limit)[:root_ids].size,
        total_roots: Group.parents_only.joins(:subscription).where(subscriptions: { plan: plan }).count
      }
    end
    puts JSON.pretty_generate(plan_counts)
  end

  desc "Silently discard topic-free free groups and expired trials older than 60 days; requires CLEANUP_ENABLED (optional LIMIT)"
  task discard_empty_groups: :environment do
    abort "CLEANUP_ENABLED must be set" unless ENV["CLEANUP_ENABLED"].present?

    limit = ENV["LIMIT"].presence&.to_i
    result = CleanupService::EMPTY_GROUP_SUBSCRIPTION_PLANS.index_with do |plan|
      CleanupService.discard_empty_groups!(plan: plan, limit: limit)
    end
    puts result.to_json
  end

  desc "Delete untouched legacy seeded discussions and polls. Supports LIMIT, SEEDED_CONTENT_TYPE, SHARD_COUNT, and SHARD_INDEX."
  task delete_unused_seeded_content: :environment do
    limit = ENV["LIMIT"].presence&.to_i
    SeededContentCleanupService.delete!(
      limit: limit,
      content_type: ENV["SEEDED_CONTENT_TYPE"].presence,
      shard_count: ENV.fetch("SHARD_COUNT", 1).to_i,
      shard_index: ENV.fetch("SHARD_INDEX", 0).to_i
    )
  end

  desc "Queue background jobs to resequence legacy topics where poll_created appears after later comments"
  task resequence_legacy_poll_created_topic_items: :environment do
    count = TopicService.enqueue_legacy_poll_created_resequence
    puts "Queued #{count} topics for legacy poll_created resequencing"
  end


end
