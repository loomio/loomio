require 'test_helper'

class TrialExtensionServiceTest < ActiveSupport::TestCase
  setup do
    @creator = User.create!(name: 'Creator', email: 'ext-creator@example.test', email_verified: true)
    @member_a = User.create!(name: 'Member A', email: 'ext-a@example.test', email_verified: true)
    @member_b = User.create!(name: 'Member B', email: 'ext-b@example.test', email_verified: true)
    @group = Group.create!(
      name: 'Trial Extension Group',
      creator: @creator,
      group_privacy: 'secret',
      subscription: Subscription.create!(
        plan: 'trial',
        state: 'active',
        expires_at: 7.days.from_now,
        max_members: 10,
        allow_subgroups: false,
        allow_guests: false
      )
    )
    @group.add_admin!(@creator)
    @group.add_member!(@member_a)
    @group.add_member!(@member_b)
  end

  test 'extends trial by 30 extra days and enables subgroups and guests when 3 members vote in a poll' do
    freeze_time do
      hosted do
        original_expires_at = @group.subscription.expires_at
        discussion = DiscussionService.create(actor: @creator, params: { group_id: @group.id, title: 'Decision thread' })
        CommentService.create(comment: Comment.new(body: 'Hello from A', parent: discussion), actor: @member_a)
        assert_equal 0, TrialExtensionService.participants_count(@group)

        poll = create_poll(discussion)
        cast_vote(poll, @creator)
        assert_equal 1, TrialExtensionService.participants_count(@group)
        assert_nil @group.subscription.reload.trial_extended_at
        refute @group.subscription.allow_subgroups
        refute @group.subscription.allow_guests

        cast_vote(poll, @member_a)
        assert_equal 2, TrialExtensionService.participants_count(@group)
        assert_nil @group.subscription.reload.trial_extended_at

        cast_vote(poll, @member_b)
        sub = @group.subscription.reload
        assert_equal 3, TrialExtensionService.participants_count(@group)
        assert_not_nil sub.trial_extended_at
        assert sub.allow_subgroups
        assert sub.allow_guests
        assert_in_delta (original_expires_at + 30.days).to_i, sub.expires_at.to_i, 2
      end
    end
  end

  test 'extension is idempotent and does not extend again' do
    hosted do
      discussion = DiscussionService.create(actor: @creator, params: { group_id: @group.id, title: 'Thread' })
      poll = create_poll(discussion)
      cast_vote(poll, @creator)
      cast_vote(poll, @member_a)
      cast_vote(poll, @member_b)

      first_extended_at = @group.subscription.reload.trial_extended_at
      first_expires_at = @group.subscription.expires_at
      assert_not_nil first_extended_at

      travel 2.days do
        assert_equal false, TrialExtensionService.check!(@group)
        assert_equal first_extended_at, @group.subscription.reload.trial_extended_at
        assert_equal first_expires_at, @group.subscription.expires_at
      end
    end
  end

  test 'non-hosted instances do not extend trials' do
    AppConfig.stub(:app_features, AppConfig.app_features.merge(subscriptions: false)) do
      discussion = DiscussionService.create(actor: @creator, params: { group_id: @group.id, title: 'Thread' })
      poll = create_poll(discussion)
      cast_vote(poll, @creator)
      cast_vote(poll, @member_a)
      cast_vote(poll, @member_b)

      assert_nil @group.subscription.reload.trial_extended_at
      refute @group.subscription.allow_subgroups
    end
  end

  private

  def create_poll(discussion)
    PollService.create(
      actor: @creator,
      params: {
        topic_id: discussion.topic_id,
        title: 'Vote',
        poll_type: 'poll',
        poll_option_names: %w[Yes No],
        closing_at: 3.days.from_now
      }
    )
  end

  def cast_vote(poll, user)
    StanceService.update(
      stance: poll.stances.latest.find_by!(participant: user),
      actor: user,
      params: { choice: { 'Yes' => 1 } }
    )
  end

  def hosted(&block)
    AppConfig.stub(:app_features, AppConfig.app_features.merge(subscriptions: true), &block)
  end
end
