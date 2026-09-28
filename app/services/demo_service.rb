class DemoService
  DEMO_GROUP_IDS_CACHE_KEY = "demo_group_ids"
  DEMO_QUEUE_LOCK_KEY = 1_573_705_781
  TEMPLATE_KEY = "mobile"

  # Keep provisioning out of the request path. Rails.cache is Redis-backed in
  # production, while the advisory lock serializes read-modify-write operations
  # across web and worker processes.
  def self.refill_queue
    return unless AppConfig.demo_groups_enabled?

    with_demo_queue_lock do
      source = ensure_source!
      ids = demo_group_ids.select { |id| queued_group(id)&.info&.dig("demo_group_digest") == source.info.fetch("demo_group_digest") }
      expected = ENV.fetch("FEATURES_DEMO_GROUPS_SIZE", 3).to_i

      [ expected - ids.size, 0 ].max.times do
        ids << DemoGroupTemplateService.prepare_clone!(source: source).id
      end

      write_demo_group_ids(ids)
    end
  end

  def self.take_demo(actor)
    claimed_result = with_demo_queue_lock do
      ids = demo_group_ids
      group = nil
      group = queued_group(ids.shift) until group || ids.empty?
      write_demo_group_ids(ids)

      ActiveRecord::Base.transaction do
        DemoGroupTemplateService.claim!(group: group, user: actor) if group
      end
    end
    result = claimed_result || with_demo_queue_lock do
      source = ensure_source!(pretranslate: false)
      group = DemoGroupTemplateService.prepare_clone!(source: source)
      DemoGroupTemplateService.claim!(group: group, user: actor)
    end
    DemoGroupTemplateService.route_notifications!(result.notifications)

    group = result.group
    if actor.locale != "en" && TranslationService.available? && source_locale_ready?(group, actor.locale)
      begin
        # Translate every record together so a quota or provider failure leaves
        # the whole walkthrough in English rather than in mixed languages.
        ApplicationRecord.transaction do
          TranslationService.translate_group_content!(group, actor.locale, false, cached_only: true)
        end
      rescue StandardError => error
        Rails.logger.warn("Demo translation skipped: #{error.class}: #{error.message}")
      end
    end

    Sentry.metrics.count("demo.start")
    EventBus.broadcast("demo_started", actor)
    group
  end

  def self.ensure_queue
    return unless AppConfig.demo_groups_enabled?

    with_demo_queue_lock do
      write_demo_group_ids(demo_group_ids.select { |id| queued_group?(id) })
    end
    refill_queue
  end

  def self.destroy_expired_demo_groups
    Group.expired_demo.find_each do |group|
      group.destroy!
    end
  end

  def self.reset_queue!
    Rails.cache.delete(DEMO_GROUP_IDS_CACHE_KEY)
  end

  def self.demo_group_ids
    Array(Rails.cache.read(DEMO_GROUP_IDS_CACHE_KEY)).map(&:to_i)
  end

  def self.write_demo_group_ids(ids)
    Rails.cache.write(DEMO_GROUP_IDS_CACHE_KEY, ids)
  end

  def self.with_demo_queue_lock
    ActiveRecord::Base.connection.execute("SELECT pg_advisory_lock(#{DEMO_QUEUE_LOCK_KEY})")
    yield
  ensure
    ActiveRecord::Base.connection.execute("SELECT pg_advisory_unlock(#{DEMO_QUEUE_LOCK_KEY})")
  end

  def self.queued_group?(id)
    queued_group(id).present?
  end
  private_class_method :queued_group?

  def self.queued_group(id)
    group = Group.where(id: id).where("info @> ?", { demo_group_queued: true }.to_json).first
    group if group&.info&.dig("demo_group_digest") == DemoGroupTemplateService.template_digest(TEMPLATE_KEY)
  end
  private_class_method :queued_group

  # The database marker survives cache eviction and process restarts. A changed
  # YAML digest replaces the source and its unclaimed queue, while claimed demos
  # remain usable with their already applied content.
  def self.ensure_source!(pretranslate: true)
    digest = DemoGroupTemplateService.template_digest(TEMPLATE_KEY)
    sources = Group.where("info @> ?", { demo_group_source: true, demo_group_template: TEMPLATE_KEY }.to_json).order(id: :desc)
    source = sources.find { |group| group.info["demo_group_digest"] == digest }
    if source
      discard_old_queued_groups!(digest)
      pretranslate_source!(source) if pretranslate
      return source
    end

    source = DemoGroupTemplateService.prepare_source!(template_key: TEMPLATE_KEY)
    sources.each do |old_source|
      Group.where("info @> ?", { demo_group_digest: old_source.info["demo_group_digest"] }.to_json).find_each do |group|
        next if group.id == old_source.id
        next if group.info["demo_group_queued"]

        group.update!(info: group.info.except("source_record_ids"))
      end
      old_source.destroy!
    end
    discard_old_queued_groups!(digest)
    pretranslate_source!(source) if pretranslate
    source
  end
  private_class_method :ensure_source!

  def self.discard_old_queued_groups!(digest)
    Group.where("info @> ?", { demo_group_queued: true, demo_group_template: TEMPLATE_KEY }.to_json).find_each do |group|
      group.destroy! if group.info["demo_group_digest"] != digest
    end
  end
  private_class_method :discard_old_queued_groups!

  def self.pretranslate_source!(source)
    return unless TranslationService.available?

    ready = Array(source.info["demo_group_locales"])
    AppConfig.locales.fetch("supported").each do |locale|
      next if locale == "en" || !TranslationService.supported_locale?(locale)

      language = TranslationService.locale_for_google(locale)
      next if ready.include?(language)

      begin
        TranslationService.translate_group_content!(source, locale, true)
        ready << language
        source.update!(info: source.info.merge("demo_group_locales" => ready))
      rescue StandardError => error
        Rails.logger.warn("Demo pretranslation skipped for #{locale}: #{error.class}: #{error.message}")
      end
    end
  end
  private_class_method :pretranslate_source!

  def self.source_locale_ready?(group, locale)
    source = Group.find_by(id: group.info.dig("source_record_ids", "Group-#{group.id}"))
    source&.info&.dig("demo_group_locales")&.include?(TranslationService.locale_for_google(locale))
  end
  private_class_method :source_locale_ready?
end
