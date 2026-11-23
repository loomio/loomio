require 'test_helper'

class EmailInvitationPermissionsTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @member = users(:user)
    @group = groups(:group)
    @subgroup = groups(:subgroup)
    @topic = topics(:discussion_topic)
    @direct_topic = topics(:direct_topic)
    @group.update!(subscription: Subscription.create!(plan: 'trial', state: 'active', max_members: 100))
  end

  test 'trial and demo subscriptions default allow_email_invitations to false and paid plans restore it' do
    refute @group.subscription.allow_email_invitations
    assert_equal false, Subscription.create!(plan: 'demo').allow_email_invitations
    assert_equal true, Subscription.create!(plan: 'free').allow_email_invitations

    @group.subscription.update!(plan: 'pro')
    assert @group.subscription.allow_email_invitations

    @group.subscription.update!(plan: 'trial')
    refute @group.subscription.allow_email_invitations
  end

  test 'explicitly enabling allow_email_invitations on a trial persists across subsequent updates' do
    @group.subscription.update!(allow_email_invitations: true)
    assert @group.subscription.reload.allow_email_invitations

    @group.subscription.update!(max_members: 50)
    assert @group.subscription.reload.allow_email_invitations

    explicit = Subscription.create!(plan: 'trial', allow_email_invitations: true)
    assert explicit.allow_email_invitations
  end

  test 'hosted trials reject email invitations across groups, threads, polls, outcomes, and direct threads' do
    poll = PollService.create(actor: @admin, params: {
      group_id: @group.id, title: 'Group poll', poll_type: 'proposal',
      poll_option_names: [ 'Agree' ], closing_at: 2.days.from_now
    })
    hosted do
      assert_no_difference [ 'User.count', 'Membership.count', 'TopicReader.count', 'Notification.count' ] do
        assert_raises(CanCan::AccessDenied) do
          GroupService.invite(group: @group, actor: @admin, params: { recipient_emails: [ 'stranger@example.test' ] })
        end
        assert_raises(CanCan::AccessDenied) do
          GroupService.invite(group: @subgroup, actor: @admin, params: { recipient_emails: [ 'stranger@example.test' ] })
        end
        assert_raises(CanCan::AccessDenied) do
          DiscussionService.create(actor: @admin, params: { group_id: @group.id, title: 'Group', recipient_emails: [ 'stranger@example.test' ] })
        end
        assert_raises(CanCan::AccessDenied) do
          DiscussionService.create(actor: @admin, params: { title: 'Direct', recipient_emails: [ 'stranger@example.test' ] })
        end
        assert_raises(CanCan::AccessDenied) do
          TopicService.invite(topic: @topic, actor: @admin, params: { recipient_emails: [ 'stranger@example.test' ] })
        end
        assert_raises(CanCan::AccessDenied) do
          TopicService.invite(topic: @direct_topic, actor: @member, params: { recipient_emails: [ 'stranger@example.test' ] })
        end
        assert_raises(CanCan::AccessDenied) do
          PollService.create(actor: @admin, params: {
            group_id: @group.id, title: 'Anon poll', poll_type: 'proposal',
            anonymous: true, specified_voters_only: true,
            poll_option_names: [ 'Agree' ], closing_at: 2.days.from_now,
            recipient_emails: [ 'stranger@example.test' ]
          })
        end
        assert_raises(CanCan::AccessDenied) do
          PollService.invite(poll: poll, actor: @admin, params: {
            recipient_emails: [ 'stranger@example.test' ], notify_recipients: true
          })
        end
        assert_raises(CanCan::AccessDenied) do
          OutcomeService.create(
            outcome: Outcome.new(poll: poll, statement: 'Outcome'),
            actor: @admin,
            params: { recipient_emails: [ 'stranger@example.test' ] }
          )
        end
        assert_raises(CanCan::AccessDenied) do
          UserInviter.authorize_preview!(model: @topic, actor: @admin, emails: [ 'stranger@example.test' ], audience: nil)
        end
        assert_raises(CanCan::AccessDenied) do
          UserInviter.where_or_create!(model: @group, actor: @admin, emails: [ 'stranger@example.test' ], user_ids: [])
        end
      end
    end
  end

  test 'server admins do not bypass allow_email_invitations on hosted trials' do
    hosted do
      @admin.update!(is_admin: true)
      assert_raises(CanCan::AccessDenied) do
        GroupService.invite(group: @group, actor: @admin, params: { recipient_emails: [ 'stranger@example.test' ] })
      end
      assert_raises(CanCan::AccessDenied) do
        TopicService.invite(topic: @topic, actor: @admin, params: { recipient_emails: [ 'stranger@example.test' ] })
      end
    end
  end

  test 'hosted trials still allow notifying existing members on group threads, subgroups, and direct threads' do
    hosted do
      discussion = DiscussionService.create(
        actor: @admin,
        params: { group_id: @group.id, title: 'Group discussion', recipient_audience: 'group' }
      )
      assert discussion.persisted?

      direct = DiscussionService.create(
        actor: @admin,
        params: { title: 'Direct discussion', recipient_user_ids: [ @member.id ] }
      )
      assert direct.persisted?
      assert direct.topic.members_include?(@member)

      memberships = GroupService.invite(
        group: @subgroup,
        actor: @admin,
        params: { recipient_user_ids: [ @member.id ] }
      )
      assert_includes memberships.map(&:user_id), @member.id
    end
  end

  test 'enabling allow_email_invitations on a trial immediately permits group and direct email invitations' do
    hosted do
      @group.subscription.update!(allow_email_invitations: true)
      assert @admin.email_invitations_allowed?

      assert_difference 'User.count', 2 do
        GroupService.invite(group: @group, actor: @admin, params: { recipient_emails: [ 'permitted-group@example.test' ] })
        DiscussionService.create(actor: @admin, params: { title: 'Permitted direct', recipient_emails: [ 'permitted-direct@example.test' ] })
      end
    end
  end

  test 'non-hosted instances ignore allow_email_invitations' do
    AppConfig.stub(:app_features, AppConfig.app_features.merge(subscriptions: false)) do
      assert_difference 'User.count', 1 do
        GroupService.invite(group: @group, actor: @admin, params: { recipient_emails: [ 'selfhosted@example.test' ] })
      end
    end
  end

  test 'demo groups, unaccepted paid memberships, and logged-out users do not grant email invitations' do
    hosted do
      refute LoggedOutUser.new.email_invitations_allowed?
      refute @member.email_invitations_allowed?

      other = groups(:alien_group)
      other.update!(subscription: Subscription.create!(plan: 'demo'))
      membership = other.add_member!(@member)
      refute @member.is_paying?
      refute @member.email_invitations_allowed?

      other.subscription.update!(plan: 'pro')
      membership.update_column(:accepted_at, nil)
      refute @member.is_paying?
      refute @member.email_invitations_allowed?

      membership.update_column(:accepted_at, Time.current)
      assert @member.is_paying?
      assert @member.email_invitations_allowed?
    end
  end

  private

  def hosted(&block)
    AppConfig.stub(:app_features, AppConfig.app_features.merge(subscriptions: true), &block)
  end
end
