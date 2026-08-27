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

  # Translation imports can contain thousands of strings. Batch requests and
  # retry transient connection and service-capacity failures without changing
  # result ordering.
  def translate_strings(google, source_strings, google_locale)
    retry_count = 0

    begin
      Array(google.translate(*source_strings, to: google_locale)).map do |translation|
        CGI.unescapeHTML(translation.text)
      end
    rescue Faraday::ConnectionFailed,
           Faraday::SSLError,
           Faraday::TimeoutError,
           Google::Cloud::ResourceExhaustedError
      retry_count += 1
      raise if retry_count > 5

      sleep(2**(retry_count - 1))
      retry
    end
  end

  # Stay below Google's per-request limits of 128 strings and 30,000 codepoints,
  # with margin for request encoding and future source-string growth.
  def translation_batches(paths, source, batch_size_max: 100, batch_length_max: 20_000)
    batches = []
    batch = []
    batch_length = 0

    paths.each do |path|
      source_string = (source.dig(*path.split('.')) || "").strip
      if batch.any? && (batch.length >= batch_size_max || batch_length + source_string.length > batch_length_max)
        batches << batch
        batch = []
        batch_length = 0
      end

      batch << [ path, source_string ]
      batch_length += source_string.length
    end

    batches << batch if batch.any?
    batches
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
    UpdateBlockedDomainsWorker.perform_later
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

  task translate_strings: :environment do
    sources = %w[server client].to_h do |source_name|
      source = YAML.load_file("config/locales/#{source_name}.en.yml")['en']
      [source_name, { strings: source, paths: list_paths(source, []) }]
    end

    output_mutex = Mutex.new
    errors = Queue.new

    AppConfig.locales['supported'].map do |file_locale|
      Thread.new do
        google = Google::Cloud::Translate.translation_v2_service
        google_locale = file_locale == 'nl_NL' ? 'nl' : file_locale

        sources.each do |source_name, source_data|
          source = source_data[:strings]
          source_paths = source_data[:paths]
          filename = "config/locales/#{source_name}.#{file_locale}.yml"

          file_was_new = !File.exist?(filename)
          foreign = {}
          foreign_paths = []
          unless file_was_new
            foreign = YAML.load_file(filename)[file_locale]
            foreign_paths = list_paths(foreign, [])
          end

          paths_missing = source_paths - foreign_paths
          paths_blank, paths_translate = paths_missing.partition do |path|
            (source.dig(*path.split('.')) || "").strip.blank?
          end

          if file_was_new
            paths_blank.each { |path| foreign.bury(*path.split('.'), "") }
            File.write(filename, { file_locale => foreign }.to_yaml(line_width: 2000)) if paths_blank.any?
          end

          translation_batches(paths_translate, source).each do |batch|
            paths, source_strings = batch.transpose

            output_mutex.synchronize do
              puts "#{file_locale}: translating #{source_name} strings #{paths.first} to #{paths.last}"
            end

            translated_strings = translate_strings(google, source_strings, google_locale)
            raise "translation count mismatch" unless translated_strings.length == paths.length

            paths.zip(translated_strings).each do |path, translated_string|
              foreign.bury(*path.split('.'), translated_string)
            end

            File.write(filename, { file_locale => foreign }.to_yaml(line_width: 2000))
          end
        end
      rescue => e
        errors << [file_locale, e]
      end
    end.each(&:join)

    unless errors.empty?
      messages = []
      messages << "Translation failed for #{errors.length} locale(s):"
      messages.concat(errors.size.times.map do
        file_locale, error = errors.pop
        "#{file_locale}: #{error.class}: #{error.message}"
      end)
      raise messages.join("\n")
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

  desc "Queue background jobs to resequence legacy topics where poll_created appears after later comments"
  task resequence_legacy_poll_created_topic_items: :environment do
    count = TopicService.enqueue_legacy_poll_created_resequence
    puts "Queued #{count} topics for legacy poll_created resequencing"
  end


end
