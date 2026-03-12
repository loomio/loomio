require 'test_helper'

class DemoServiceTest < ActiveSupport::TestCase
  def create_demo_scenario
    admin = User.create!(email: "demoadmin#{SecureRandom.hex(4)}@example.com", name: 'Demo Admin', password: 'password')
    member = User.create!(email: "demomember#{SecureRandom.hex(4)}@example.com", name: 'Demo Member', password: 'password')

    group = Group.create!(name: "demogroup#{SecureRandom.hex(4)}", creator_id: admin.id)
    group.add_admin!(admin)
    group.add_member!(member)

    tag = Tag.create!(name: "demotag#{SecureRandom.hex(4)}", group: group, color: '#ff0000')

    discussion = Discussion.create!(
      title: "demo_discussion#{SecureRandom.hex(4)}",
      group: group,
      author: admin,
      tags: [tag.name]
    )
    Comment.create!(body: 'demo comment', discussion: discussion, author: admin)

    poll = Poll.create!(
      title: "demo_poll#{SecureRandom.hex(4)}",
      group: group,
      author: admin,
      poll_type: 'proposal',
      closing_at: 1.day.from_now,
      opened_at: Time.now
    )
    PollOption.create!(poll: poll, name: 'agree')
    PollOption.create!(poll: poll, name: 'disagree')

    Stance.create!(poll: poll, participant: admin, choice: 'agree')
    poll.update_counts!

    Event.create!(eventable: discussion, user: admin, kind: 'discussion_created')

    {
      admin: admin, member: member,
      group: group,
      discussion: discussion, poll: poll, tag: tag
    }
  end

  def export_demo_json(group, recorded_at: 1.week.ago)
    filename = GroupExportService.export(group.all_groups, group.name)
    json_path = Rails.root.join('tmp', "demo_test_#{SecureRandom.hex(4)}.json")
    metadata_path = Rails.root.join('tmp', "demo_metadata_#{SecureRandom.hex(4)}.yml")
    FileUtils.cp(filename, json_path)
    File.write(metadata_path, { 'recorded_at' => recorded_at.iso8601 }.to_yaml)
    [json_path, metadata_path]
  end

  setup do
    @data = create_demo_scenario
    @json_path, @metadata_path = export_demo_json(@data[:group])
    @user = users(:normal_user)
    ActionMailer::Base.deliveries.clear
  end

  teardown do
    File.delete(@json_path) if @json_path && File.exist?(@json_path)
    File.delete(@metadata_path) if @metadata_path && File.exist?(@metadata_path)
    Redis::List.new('demo_group_ids').clear
  end

  # -- create_clone_group_from_json --

  test "creates group from json with all records" do
    recorded_at = 1.week.ago
    cloner = RecordCloner.new(recorded_at: recorded_at)
    group = cloner.create_clone_group_from_json(@json_path)

    assert group.persisted?
    assert_nil group.handle
    assert_equal false, group.is_visible_to_public

    # users are reused (already exist)
    admin = User.find_by!(email: @data[:admin].email)
    assert_equal @data[:admin].id, admin.id

    # discussion imported
    imported_discussion = Discussion.find_by!(title: @data[:discussion].title, group: group)
    assert_equal admin.id, imported_discussion.author_id

    # comment imported
    Comment.find_by!(discussion: imported_discussion, body: 'demo comment')

    # poll imported with options and stances
    imported_poll = Poll.find_by!(title: @data[:poll].title, group: group)
    assert_equal 2, imported_poll.poll_options.count
    assert imported_poll.stances.count >= 1

    # tag imported
    Tag.find_by!(name: @data[:tag].name, group: group)
  end

  test "wind_dates shifts timestamps forward" do
    recorded_at = 7.days.ago
    cloner = RecordCloner.new(recorded_at: recorded_at)
    group = cloner.create_clone_group_from_json(@json_path)

    imported_discussion = Discussion.find_by!(title: @data[:discussion].title, group: group)
    # created_at should be shifted forward by ~7 days from the original
    assert imported_discussion.created_at > @data[:discussion].created_at
  end

  test "generates fresh tokens and keys" do
    cloner = RecordCloner.new(recorded_at: 1.week.ago)
    group = cloner.create_clone_group_from_json(@json_path)

    imported_discussion = Discussion.find_by!(title: @data[:discussion].title, group: group)
    assert_not_equal @data[:discussion].key, imported_discussion.key
  end

  test "reuses existing users by email" do
    user_count_before = User.count
    cloner = RecordCloner.new(recorded_at: 1.week.ago)
    cloner.create_clone_group_from_json(@json_path)

    # no new users created since admin and member already exist
    assert_equal user_count_before, User.count
  end

  # -- DemoService.create_demo_group --

  test "create_demo_group creates a group with demo subscription" do
    stub_demo_paths do
      group = DemoService.create_demo_group
      assert group.persisted?
      assert_nil group.handle
      assert_equal false, group.is_visible_to_public
      assert_equal 'demo', group.subscription.plan
    end
  end

  test "create_demo_group raises when json missing" do
    assert_raises(RuntimeError, /Demo data not found/) do
      # default paths point to db/demo/ which has no demo.json in test
      DemoService.create_demo_group
    end
  end

  # -- DemoService.refill_queue --

  test "refill_queue populates redis list" do
    stub_demo_paths do
      with_env('FEATURES_DEMO_GROUPS' => '1', 'FEATURES_DEMO_GROUPS_SIZE' => '2') do
        DemoService.refill_queue
        list = Redis::List.new('demo_group_ids').value
        assert_equal 2, list.size
        list.each do |id|
          group = Group.find(id)
          assert group.persisted?
        end
      end
    end
  end

  test "refill_queue does nothing without env var" do
    DemoService.refill_queue
    assert_equal 0, Redis::List.new('demo_group_ids').value.size
  end

  # -- DemoService.take_demo --

  test "take_demo assigns group to actor" do
    stub_demo_paths do
      with_env('FEATURES_DEMO_GROUPS' => '1', 'FEATURES_DEMO_GROUPS_SIZE' => '1') do
        DemoService.refill_queue
      end

      group = DemoService.take_demo(@user)
      assert_equal @user.id, group.creator_id
      assert_equal 'demo', group.subscription.plan
      assert_equal @user.id, group.subscription.owner_id
      assert group.members.include?(@user)
    end
  end

  # -- DemoService.ensure_queue --

  test "ensure_queue removes stale ids and refills" do
    stub_demo_paths do
      with_env('FEATURES_DEMO_GROUPS' => '1', 'FEATURES_DEMO_GROUPS_SIZE' => '1') do
        # push a non-existent group id
        Redis::List.new('demo_group_ids').push(999_999_999)
        DemoService.ensure_queue
        list = Redis::List.new('demo_group_ids').value
        assert_equal 1, list.size
        assert_not_equal '999999999', list.first
      end
    end
  end

  private

  def stub_demo_paths(&block)
    original_json = DemoService::DEMO_JSON_PATH
    original_meta = DemoService::METADATA_PATH
    DemoService.send(:remove_const, :DEMO_JSON_PATH)
    DemoService.send(:remove_const, :METADATA_PATH)
    DemoService.const_set(:DEMO_JSON_PATH, @json_path)
    DemoService.const_set(:METADATA_PATH, @metadata_path)
    yield
  ensure
    DemoService.send(:remove_const, :DEMO_JSON_PATH)
    DemoService.send(:remove_const, :METADATA_PATH)
    DemoService.const_set(:DEMO_JSON_PATH, original_json)
    DemoService.const_set(:METADATA_PATH, original_meta)
  end

  def with_env(vars)
    old_values = vars.map { |k, _| [k, ENV[k]] }.to_h
    vars.each { |k, v| ENV[k] = v }
    yield
  ensure
    old_values.each { |k, v| ENV[k] = v }
  end
end
