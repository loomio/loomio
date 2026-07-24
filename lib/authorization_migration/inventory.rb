require "csv"
require "fileutils"
require "pathname"
require "set"

module AuthorizationMigration
  class Inventory
    ROUTES_HEADER = %w[
      route_key verb path controller action environment owner disposition
    ].freeze

    ACTION_FIELDS = %w[
      action_id status risk authorization_mode current_loader current_cancan
      target_policy target_query base_scope parent_constraint response_type
      response_records sensitive_fields response_proof actors dimensions
      baseline_tests policy_tests request_tests negative_tests composition_tests
      decision_differences review commit verified_at notes
    ].freeze

    STATUS_VALUES = %w[
      inventoried characterized policy_written dual_running enforced verified
      complete
    ].freeze

    COMPLETE_REQUIRED_FIELDS = %w[
      authorization_mode target_policy target_query response_type response_proof
      policy_tests request_tests negative_tests decision_differences review
      commit verified_at
    ].freeze

    Route = Data.define(
      :route_key,
      :verb,
      :path,
      :controller,
      :action,
      :environment,
      :owner,
      :disposition
    ) do
      def action_id
        "#{controller}##{action}"
      end

      def first_party_production?
        owner == "first_party_production"
      end
    end

    Result = Data.define(
      :routes_count,
      :actions_count,
      :complete_count,
      :remaining_count,
      :status_counts,
      :routes_untracked,
      :routes_stale,
      :trackers_invalid,
      :reviews_pending,
      :next_actions
    ) do
      def exit_status
        return 2 if routes_untracked.any? || routes_stale.any? || trackers_invalid.any?
        return 1 if remaining_count.positive? || reviews_pending.positive?

        0
      end
    end

    attr_reader :root

    def initialize(root:)
      @root = Pathname(root)
    end

    def routes_live
      Rails.application.routes.routes.filter_map do |route|
        controller = route.defaults[:controller].to_s
        action = route.defaults[:action].to_s
        next if controller.empty? || action.empty?

        verb = route.verb.to_s.delete_prefix("^").delete_suffix("$")
        verb = "ANY" if verb.empty?
        path = route.path.spec.to_s.sub("(.:format)", "")
        owner = owner_for(controller)
        environment = environment_for(owner)
        disposition = owner == "first_party_production" ? "migrate" : "review"
        route_key = [verb, path, controller, action].join("|")

        Route.new(
          route_key: route_key,
          verb: verb,
          path: path,
          controller: controller,
          action: action,
          environment: environment,
          owner: owner,
          disposition: disposition
        )
      end.uniq(&:route_key).sort_by(&:route_key)
    end

    def update!
      routes = routes_live
      FileUtils.mkdir_p(tracker_directory)
      FileUtils.mkdir_p(controller_directory)
      write_routes(routes)
      write_missing_action_trackers(routes)
      write_supporting_files
      result = check(routes:)
      write_coverage(result)
      result
    end

    def status
      check(routes: read_routes)
    end

    def check(routes: routes_live)
      snapshot = read_routes
      live_keys = routes.map(&:route_key).to_set
      snapshot_keys = snapshot.map(&:route_key).to_set
      actions = read_action_trackers
      production_actions = routes.select(&:first_party_production?).group_by(&:action_id)
      trackers_invalid = validate_action_trackers(actions, production_actions)
      review_action_ids = routes.reject(&:first_party_production?).map(&:action_id).uniq.to_set
      reviews, review_errors = read_reviews(review_action_ids)
      trackers_invalid.concat(review_errors)
      trackers_invalid.concat(
        routes.select { |route| route.owner == "unknown" }.map do |route|
          "#{route.action_id}: route owner is unknown"
        end
      )
      status_counts = Hash.new(0)
      production_actions.each_key do |action_id|
        status_counts[actions.fetch(action_id, {})["status"] || "missing"] += 1
      end
      complete_count = status_counts["complete"]
      next_actions = production_actions.keys.filter_map do |action_id|
        fields = actions[action_id]
        next if fields.nil? || fields["status"] == "complete"

        [action_id, fields["status"], fields["risk"]]
      end.sort_by do |action_id, status, risk|
        [
          status == "inventoried" ? 1 : 0,
          -(STATUS_VALUES.index(status) || -1),
          risk == "high" ? 0 : 1,
          action_id
        ]
      end

      Result.new(
        routes_count: routes.length,
        actions_count: production_actions.length,
        complete_count: complete_count,
        remaining_count: production_actions.length - complete_count,
        status_counts: status_counts,
        routes_untracked: (live_keys - snapshot_keys).to_a.sort,
        routes_stale: (snapshot_keys - live_keys).to_a.sort,
        trackers_invalid: trackers_invalid.sort,
        reviews_pending: (review_action_ids - reviews).count,
        next_actions: next_actions.first(10)
      )
    end

    def format(result, remaining_only: false)
      if remaining_only
        return result.next_actions.map do |action_id, status, risk|
          "#{action_id}\t#{status}\t#{risk}"
        end.join("\n")
      end

      lines = [
        "Pundit migration",
        Kernel.format("  routes:               %5d", result.routes_count),
        Kernel.format("  first-party actions:  %5d", result.actions_count),
        Kernel.format("  complete:             %5d", result.complete_count),
        Kernel.format("  remaining:            %5d", result.remaining_count),
        Kernel.format("  reviews pending:      %5d", result.reviews_pending),
        Kernel.format("  untracked routes:     %5d", result.routes_untracked.length),
        Kernel.format("  stale tracked routes: %5d", result.routes_stale.length),
        Kernel.format("  invalid trackers:     %5d", result.trackers_invalid.length)
      ]
      status_summary = STATUS_VALUES.filter_map do |status|
        count = result.status_counts.fetch(status, 0)
        "#{status}=#{count}" if count.positive?
      end
      lines << "  action status:         #{status_summary.join(", ")}"

      unless result.next_actions.empty?
        lines << ""
        lines << "Next:"
        result.next_actions.each do |action_id, status, risk|
          lines << Kernel.format("  %-42s %-14s %s", action_id, status, risk)
        end
      end

      append_details(lines, "Untracked routes", result.routes_untracked)
      append_details(lines, "Stale tracked routes", result.routes_stale)
      append_details(lines, "Invalid trackers", result.trackers_invalid)
      lines.join("\n")
    end

    private

    def tracker_directory
      root.join("docs/authorization_migration")
    end

    def controller_directory
      tracker_directory.join("controllers")
    end

    def routes_path
      tracker_directory.join("routes.tsv")
    end

    def owner_for(controller)
      return "development_only" if controller.start_with?("dev/", "rails/")
      return "active_admin_generated" if controller.start_with?("admin/")

      controller_path = root.join("app/controllers/#{controller}_controller.rb")
      return "first_party_production" if controller_path.exist?

      return "mounted_engine" if controller.start_with?(
        "action_mailbox/",
        "active_storage/",
        "mission_control/",
        "turbo/"
      )
      return "mounted_engine" if %w[
        api/v1/webhooks
        contact_messages
      ].include?(controller)

      "unknown"
    end

    def environment_for(owner)
      owner == "development_only" ? "development" : "production"
    end

    def write_routes(routes)
      CSV.open(routes_path, "w", col_sep: "\t", write_headers: true, headers: ROUTES_HEADER) do |csv|
        routes.each do |route|
          csv << ROUTES_HEADER.map { |field| route.public_send(field) }
        end
      end
    end

    def read_routes
      return [] unless routes_path.exist?

      CSV.read(routes_path, headers: true, col_sep: "\t").map do |row|
        Route.new(**ROUTES_HEADER.to_h { |field| [field.to_sym, row[field].to_s] })
      end
    end

    def write_missing_action_trackers(routes)
      existing = read_action_trackers
      routes.select(&:first_party_production?).group_by(&:controller).sort.each do |controller, controller_routes|
        missing = controller_routes.group_by(&:action_id).reject { |action_id, _| existing.key?(action_id) }
        path = controller_directory.join("#{controller.tr("/", "_")}_controller.txt")
        content = path.exist? ? path.read.rstrip : tracker_header(controller)
        additions = missing.sort.map do |action_id, action_routes|
          action_tracker(action_id, action_routes)
        end
        content = [content, *additions].join("\n\n")
        content = synchronize_route_aliases(content, controller, controller_routes)
        path.write(content.rstrip + "\n")
      end
    end

    def synchronize_route_aliases(content, controller, routes)
      routes_by_action = routes.group_by(&:action).transform_values do |action_routes|
        action_routes.map { |route| "#{route.verb} #{route.path}" }.join(" | ")
      end

      content.gsub(/^(\[action ([^\]]+)\]\nroutes = ).*$/) do
        action = Regexp.last_match(2)
        route_list = routes_by_action.fetch(action) do
          raise "Tracker #{controller}##{action} has no live route"
        end
        "#{Regexp.last_match(1)}#{route_list}"
      end
    end

    def tracker_header(controller)
      <<~TEXT.rstrip
        # Authorization migration tracker
        # controller = #{controller}
        # Update each action as its evidence is added. Do not delete route aliases.
      TEXT
    end

    def action_tracker(action_id, routes)
      controller, action = action_id.split("#", 2)
      risk = high_risk?(controller, action) ? "high" : "unclassified"
      route_list = routes.map { |route| "#{route.verb} #{route.path}" }.join(" | ")

      values = ACTION_FIELDS.to_h { |field| [field, ""] }
      values.merge!(
        "action_id" => action_id,
        "status" => "inventoried",
        "risk" => risk,
        "authorization_mode" => "undecided",
        "decision_differences" => "undecided",
        "review" => "pending"
      )

      lines = ["[action #{action}]", "routes = #{route_list}"]
      ACTION_FIELDS.each do |field|
        value = values.fetch(field)
        lines << (value.empty? ? "#{field} =" : "#{field} = #{value}")
      end
      lines.join("\n")
    end

    def high_risk?(controller, action)
      [controller, action].join("/").match?(
        %r{session|login|identity|registration|impersonat|poll|stance|vote|receipt|voter|result|event|topic|membership|invitation|attachment|export}
      )
    end

    def read_action_trackers
      controller_directory.glob("*.txt").each_with_object({}) do |path, actions|
        current = nil
        path.each_line.with_index(1) do |line, line_number|
          line = line.chomp
          if (match = line.match(/\A\[action ([^\]]+)\]\s*\z/))
            current = {"_path" => path.relative_path_from(root).to_s, "_line" => line_number.to_s}
          elsif current && (match = line.match(/\A([a-z_]+)\s*=\s*(.*)\z/))
            current[match[1]] = match[2].strip
            if match[1] == "action_id"
              actions[current["action_id"]] = current
            end
          end
        end
      end
    end

    def validate_action_trackers(actions, production_actions)
      errors = []

      production_actions.each_key do |action_id|
        fields = actions[action_id]
        if fields.nil?
          errors << "#{action_id}: missing action tracker"
          next
        end

        status = fields["status"]
        errors << "#{action_id}: invalid status #{status.inspect}" unless STATUS_VALUES.include?(status)

        missing_fields = ACTION_FIELDS.reject { |field| fields.key?(field) }
        unless missing_fields.empty?
          errors << "#{action_id}: missing fields #{missing_fields.join(", ")}"
        end

        next unless status == "complete"

        incomplete = COMPLETE_REQUIRED_FIELDS.select do |field|
          fields[field].to_s.empty? || %w[undecided pending].include?(fields[field])
        end
        unless incomplete.empty?
          errors << "#{action_id}: complete without #{incomplete.join(", ")}"
        end
      end

      actions.each_key do |action_id|
        errors << "#{action_id}: tracker has no live production route" unless production_actions.key?(action_id)
      end

      errors.sort
    end

    def write_supporting_files
      write_unless_exists(
        tracker_directory.join("README.txt"),
        <<~TEXT
          This directory is the source of truth for the CanCan to Pundit migration.

          Run:
            bin/pundit-migration-status
            bin/pundit-migration-status --remaining
            bin/pundit-migration-status --update

          The command boots the normal development environment and uses
          DATABASE_URL from the initialized login-shell environment.

          See PUNDIT_MIGRATION_PLAN.md for the tracker format, status meanings,
          migration invariants, and stop/resume procedure.
        TEXT
      )
      write_unless_exists(
        tracker_directory.join("exceptions.txt"),
        "# action_id | status | reason | reviewed_by | reviewed_at\n"
      )
      write_unless_exists(
        tracker_directory.join("decisions.txt"),
        "# Durable authorization architecture and behaviour decisions\n"
      )
      write_unless_exists(
        tracker_directory.join("findings.txt"),
        "# Security findings discovered during the Pundit migration\n"
      )
    end

    def read_reviews(review_action_ids)
      path = tracker_directory.join("exceptions.txt")
      return [Set.new, []] unless path.exist?

      reviewed = Set.new
      errors = []
      path.each_line.with_index(1) do |line, line_number|
        line = line.strip
        next if line.empty? || line.start_with?("#")

        fields = line.split("|", 5).map(&:strip)
        fields.fill("", fields.length...5)
        action_id, status, reason, reviewed_by, reviewed_at = fields
        unless review_action_ids.include?(action_id)
          errors << "exceptions.txt:#{line_number}: #{action_id.inspect} has no reviewable live route"
          next
        end
        unless %w[pending reviewed].include?(status)
          errors << "exceptions.txt:#{line_number}: invalid status #{status.inspect}"
          next
        end
        next if status == "pending"

        if [reason, reviewed_by, reviewed_at].any?(&:empty?)
          errors << "exceptions.txt:#{line_number}: reviewed entry lacks reason, reviewer, or date"
          next
        end
        reviewed << action_id
      end
      [reviewed, errors]
    end

    def write_unless_exists(path, content)
      path.write(content) unless path.exist?
    end

    def write_coverage(result)
      tracker_directory.join("coverage.txt").write(format(result) + "\n")
    end

    def append_details(lines, heading, entries)
      return if entries.empty?

      lines << ""
      lines << "#{heading}:"
      entries.first(20).each { |entry| lines << "  #{entry}" }
      lines << "  ... #{entries.length - 20} more" if entries.length > 20
    end
  end
end
