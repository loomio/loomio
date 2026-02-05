require 'test_helper'

class RecordClonerTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @group = groups(:test_group)
    @group.add_member!(@user) unless @group.members.include?(@user)
    @discussion = create_discussion(group: @group, author: @user)

    # Create poll
    @poll = Poll.new(
      title: 'Test Poll',
      author: @user,
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      poll_option_names: ['agree', 'disagree'],
      discussion: @discussion
    )
    PollService.create(poll: @poll, actor: @user)
    @poll.reload
  end

  test "clones a poll with correct attributes" do
    clone = RecordCloner.new(recorded_at: 2.days.ago).new_clone_poll(@poll)
    clone.save!
    clone.reload

    # Check basic fields
    assert_equal @poll.title, clone.title
    assert_equal @poll.details, clone.details
    assert_equal @poll.details_format, clone.details_format
    assert clone.closing_at > @poll.closing_at
    assert clone.created_at > @poll.created_at

    # Check poll options are cloned
    assert_equal @poll.poll_options.count, clone.poll_options.count
    assert_equal @poll.poll_options.first.name, clone.poll_options.first.name
  end

  test "clones a discussion with basic attributes" do
    clone = RecordCloner.new(recorded_at: 2.days.ago).new_clone_discussion_and_events(@discussion)
    clone.save!
    clone.reload

    assert_equal @discussion.title, clone.title
    assert_equal @discussion.description, clone.description
    assert_equal @discussion.description_format, clone.description_format
  end
end
