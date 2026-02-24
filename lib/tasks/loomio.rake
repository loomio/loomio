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

  task update_blocked_domains: :environment do
    UpdateBlockedDomainsWorker.perform_async
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
    # I edit this each time I want to use it.. rake task arguments are terrible
    unwanted = %w[
      start_a_new_discussion
    ]

    %w[client server].each do |source_name|
      AppConfig.locales['supported'].each do |locale|
        next if locale == 'en'
        foreign = YAML.load_file("config/locales/#{source_name}.#{locale}.yml")[locale]
        delete_keys(foreign, unwanted)
        File.write("config/locales/#{source_name}.#{locale}.yml", {locale => foreign}.to_yaml(line_width: 2000))
      end
    end
  end

  task translate_strings: :environment do
    %w[server client].each do |source_name|
      source = YAML.load_file("config/locales/#{source_name}.en.yml")['en']
      source_paths = list_paths(source, [])
      google = Google::Cloud::Translate.translation_v2_service

      AppConfig.locales['supported'].each do |file_locale|
        foreign = {}
        foreign_paths = []
        if File.exist?("config/locales/#{source_name}.#{file_locale}.yml")
          foreign = YAML.load_file("config/locales/#{source_name}.#{file_locale}.yml")[file_locale]
          foreign_paths = list_paths(foreign, [])
        end

        write_file = false
        (source_paths - foreign_paths).each do |path|
          puts "#{file_locale}: #{path}, #{source.dig(*path.split('.'))}"
          source_string = (source.dig(*path.split('.')) || "").strip
          next if source_string.blank?
          write_file = true

          google_locale = file_locale
          google_locale = 'nl' if file_locale == 'nl_NL'

          translated_string = CGI.unescapeHTML(google.translate(source_string, to: google_locale))
          foreign.bury(*path.split('.'), translated_string)
        end

        if write_file
          File.write("config/locales/#{source_name}.#{file_locale}.yml", {file_locale => foreign}.to_yaml(line_width: 2000))
        end
      end
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
        File.open("public/#{code}.#{format}", "w") do |f|
          if format == "html"
            f << "<!-- This file is automatically generated by rake loomio:generate_static_error_pages -->\n"
            f << "<!-- Don't make changes here; they will be overwritten. -->\n"
          end
          f << ApplicationController.new.render_to_string(
            locals: {
              '@title': I18n.t("errors.#{code}.title"),
              '@body': I18n.t("errors.#{code}.body"),
            },
            template: "application/error",
            layout: "basic",
            format: format
          )
        end
      end
    end
  end

  task hourly_tasks: :environment do
    puts "#{DateTime.now.iso8601} Loomio hourly tasks"
    ThrottleService.reset!('hour')
    GenericWorker.perform_async('PollService', 'expire_lapsed_polls')
    GenericWorker.perform_async('PollService', 'publish_closing_soon')
    GenericWorker.perform_async('PollService', 'open_scheduled_polls')
    GenericWorker.perform_async('TaskService', 'send_task_reminders')
    GenericWorker.perform_async('ReceivedEmailService', 'route_all')
    LoginToken.where("created_at < ?", 1.hours.ago).delete_all
    Identity.stale(days: 7).delete_all
    GeoLocationWorker.perform_async

    SendDailyCatchUpEmailWorker.perform_async

    if (Time.now.hour == 0)
      ThrottleService.reset!('day')
      Group.expired_demo.delete_all
      GenericWorker.perform_async('DemoService', 'generate_demo_groups')
      GenericWorker.perform_async('CleanupService', 'delete_orphan_records')
      GenericWorker.perform_async('CleanupService', 'warn_and_destroy_expired_trial_groups')
      GenericWorker.perform_async('CleanupService', 'destroy_orphan_users')
      GenericWorker.perform_async('OutcomeService', 'publish_review_due')
      GenericWorker.perform_async('ReceivedEmailService', 'delete_old_emails')
    end

    GenericWorker.perform_async('DemoService', 'ensure_queue')

    if (Time.now.hour == 0 && Time.now.mday == 1)
      UpdateBlockedDomainsWorker.perform_async
    end
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
      GenericWorker.perform_async('SubscriptionService', 'refresh_expiring_management_links')
    end
  end

  task populate_chargify_management_links: :environment do
    if Date.today.sunday?
      GenericWorker.perform_async('SubscriptionService', 'populate_management_links')
    end
  end

end
