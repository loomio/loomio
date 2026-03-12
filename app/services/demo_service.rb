class DemoService
  DEMO_JSON_PATH = Rails.root.join('db/demo/demo.json')
  METADATA_PATH  = Rails.root.join('db/demo/metadata.yml')

  def self.create_demo_group
    raise "Demo data not found at #{DEMO_JSON_PATH}" unless File.exist?(DEMO_JSON_PATH)

    metadata = YAML.load_file(METADATA_PATH)
    recorded_at = Time.parse(metadata['recorded_at'])

    cloner = RecordCloner.new(recorded_at: recorded_at)
    group = cloner.create_clone_group_from_json(DEMO_JSON_PATH)
    group.handle = nil
    group.is_visible_to_public = false
    group.subscription = Subscription.new(plan: 'demo')
    group.save!

    group
  end

  def self.refill_queue
    return unless ENV['FEATURES_DEMO_GROUPS']
    return unless File.exist?(DEMO_JSON_PATH)

    expected = ENV.fetch('FEATURES_DEMO_GROUPS_SIZE', 3).to_i
    remaining = Redis::List.new('demo_group_ids').value.size

    (expected - remaining).times do
      group = create_demo_group
      Redis::List.new('demo_group_ids').push(group.id)
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
    return unless ENV['FEATURES_DEMO_GROUPS']

    existing_ids = Redis::List.new('demo_group_ids').value.select { |id| Group.where(id: id).exists? }
    Redis::List.new('demo_group_ids').clear
    Redis::List.new('demo_group_ids').unshift(*existing_ids) if existing_ids.any?
    refill_queue
  end
end
