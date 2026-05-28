class DemoService
  def self.refill_queue
    return unless ENV['DEMO_GROUP_ID']

    group = Group.find(ENV['DEMO_GROUP_ID'])

    # precache translations
    AppConfig.locales['supported'].each do |locale|
      TranslationService.translate_group_content!(group, locale, true)
    end

    expected = ENV.fetch('FEATURES_DEMO_GROUPS_SIZE', 3)
    remaining = Redis::List.new('demo_group_ids').value.size

    (expected - remaining).times do
      clone = RecordCloner.new(recorded_at: group.created_at).create_clone_group(group)
      Redis::List.new('demo_group_ids').push(clone.id)
    end
  end

  def self.take_demo(actor)
    group = Group.find(Redis::List.new('demo_group_ids').shift)
    group.creator = actor
    group.subscription = Subscription.new(plan: 'demo', owner: actor)
    group.save!
    group.add_member! actor
    group.save!

    TranslationService.translate_group_content!(group, actor.locale) if actor.locale != 'en'

    EventBus.broadcast('demo_started', actor)
    group
  end

  def self.ensure_queue
    return unless ENV['DEMO_GROUP_ID']

    existing_ids = Redis::List.new('demo_group_ids').value.select { |id| Group.where(id: id).exists? }
    Redis::List.new('demo_group_ids').clear
    Redis::List.new('demo_group_ids').unshift(*existing_ids) if existing_ids.any?
    refill_queue
  end
end
