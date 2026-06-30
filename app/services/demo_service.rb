class DemoService
  DEMO_GROUP_IDS_CACHE_KEY = 'demo_group_ids'
  DEMO_QUEUE_LOCK_KEY = 1_573_705_781

  def self.refill_queue
    return unless ENV['FEATURES_DEMO_GROUPS']

    demo = Demo.where('demo_handle is not null').last
    return unless demo

    # precache translations
    AppConfig.locales['supported'].each do |locale|
      TranslationService.translate_group_content!(demo.group, locale, true)
    end

    with_demo_queue_lock do
      ids = demo_group_ids
      expected = ENV.fetch('FEATURES_DEMO_GROUPS_SIZE', 3).to_i

      (expected - ids.size).times do
        group = RecordCloner.new(recorded_at: demo.recorded_at).create_clone_group(demo.group)
        ids.push(group.id)
      end

      write_demo_group_ids(ids)
    end
  end

  def self.take_demo(actor)
    group_id = with_demo_queue_lock do
      ids = demo_group_ids
      ids.shift.tap { write_demo_group_ids(ids) }
    end

    group = Group.find(group_id)
    group.creator = actor
    group.subscription = Subscription.new(plan: 'demo', owner: actor)
    group.save!
    group.add_member! actor
    group.save!

    TranslationService.translate_group_content!(group, actor.locale) if actor.locale != 'en'

    Sentry.metrics.count("demo.start")
    EventBus.broadcast('demo_started', actor)
    group
  end

  def self.ensure_queue
    return unless ENV['FEATURES_DEMO_GROUPS']

    with_demo_queue_lock do
      existing_ids = demo_group_ids.select { |id| Group.where(id: id).exists? }
      write_demo_group_ids(existing_ids)
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
    Rails.cache.fetch(DEMO_GROUP_IDS_CACHE_KEY) { [] }
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
end
