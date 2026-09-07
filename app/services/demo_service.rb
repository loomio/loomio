class DemoService
  DEMO_GROUP_IDS_CACHE_KEY = "demo_group_ids"
  DEMO_QUEUE_LOCK_KEY = 1_573_705_781
  TEMPLATE_KEY = "mobile"

  # Keep provisioning out of the request path. Rails.cache is Redis-backed in
  # production, while the advisory lock serializes read-modify-write operations
  # across web and worker processes.
  def self.refill_queue
    return unless ENV.key?("FEATURES_DEMO_GROUPS")

    with_demo_queue_lock do
      ids = demo_group_ids.select { |id| queued_group?(id) }
      expected = ENV.fetch("FEATURES_DEMO_GROUPS_SIZE", 3).to_i

      [ expected - ids.size, 0 ].max.times do
        ids << DemoGroupTemplateService.prepare!(template_key: TEMPLATE_KEY).group.id
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
    result = claimed_result || DemoGroupTemplateService.create!(template_key: TEMPLATE_KEY, user: actor)
    DemoGroupTemplateService.route_notifications!(result.notifications) if claimed_result

    group = result.group
    TranslationService.translate_group_content!(group, actor.locale) if actor.locale != "en"

    Sentry.metrics.count("demo.start")
    EventBus.broadcast("demo_started", actor)
    group
  end

  def self.ensure_queue
    return unless ENV.key?("FEATURES_DEMO_GROUPS")

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
    Group.where(id: id).where("info @> ?", { demo_group_queued: true }.to_json).first
  end
  private_class_method :queued_group
end
