require 'rails_helper'

describe API::AnnouncementsController do
  let(:user)  { create :user }
  let(:group) { create :formal_group }
  let(:another_group) { create :formal_group, parent: group }
  let(:an_unknown_group) { create :formal_group }

  before do
    group.add_admin! user
    sign_in user
  end

  describe 'search' do
    let!(:a_friend)        { create :user, name: "Friendly Fran" }
    let!(:an_acquaintance) { create :user, name: "Acquaintance Annie" }
    let!(:a_stranger)      { create :user, name: "Alien Alan" }
    let(:subgroup) { create :formal_group, parent: group}

    before do
      group.add_member! user
      group.add_member! a_friend
      another_group.add_member! user
      another_group.add_member! an_acquaintance
    end

    it 'does not return an existing user you dont know' do
      get :search, params: { q: 'alien', group_id: group.id }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json).to be_empty
    end

    it 'returns an email address' do
      get :search, params: { q: 'bumble@bee.com', group_id: group.id }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json[0]['name']).to eq 'bumble@bee.com'
    end

    it 'finds members in your group but not this subgroup' do
      get :search, params: { q: 'annie', group_id: group.id }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json[0]['name']).to eq an_acquaintance.name
    end

    it 'filters out group members if a group is given' do
      get :search, params: { q: 'fran', group_id: group.id }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json).to be_empty
    end

    it 'filters out group member email addresses' do
      get :search, params: { q: a_friend.email, group_id: group.id }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json).to be_empty
    end

    it 'authorizes the group' do
      get :search, params: { q: 'annie', group_id: an_unknown_group.id }
      expect(response.status).to eq 403
    end
  end

  describe 'audience' do
    let(:group)      { create :formal_group }
    let(:discussion) { create :discussion, group: group }
    let(:subgroup)   { create :formal_group, parent: group }
    let(:both_user)  { create :user }
    let(:parent_user){ create :user }

    it 'parent_group' do
      group.add_member! both_user
      subgroup.add_member! both_user
      group.add_member! parent_user
      subgroup.add_admin! user

      get :audience, params: {group_id: subgroup.id, kind: "parent_group"}
      json = JSON.parse response.body
      user_ids = json.map {|u| u['id']}
      expect(user_ids).to     include parent_user.id
      expect(user_ids).to_not include both_user.id
      expect(user_ids).to_not include user.id
    end

    it 'formal_group' do
      get :audience, params: {discussion_id: discussion.id, kind: "formal_group"}
      json = JSON.parse response.body
      expect(json.map {|u| u['id']}.sort).to eq group.member_ids.reject{|id| id == user.id}.sort
    end

    it 'discussion_group' do
      guest = create :user
      discussion.guest_group.add_member! guest
      get :audience, params: {discussion_id: discussion.id, kind: "discussion_group"}
      json = JSON.parse response.body
      expect(json.map {|u| u['id']}.sort).to eq Array(guest.id)
    end

    it 'voters' do
      poll = create :poll, author: user
      stance = create :stance, poll: poll
      get :audience, params: {poll_id: poll.id, kind: "voters"}
      json = JSON.parse response.body
      expect(json.map {|u| u['id']}.sort).to eq Array(stance.participant.id)
    end

    it 'non_voters' do
      poll = create :poll, author: user
      guest = create :user
      stance = create :stance, poll: poll
      poll.guest_group.add_member! guest

      get :audience, params: {poll_id: poll.id, kind: "non_voters"}
      json = JSON.parse response.body
      expect(json.map {|u| u['id']}.sort).to include guest.id
      expect(json.map {|u| u['id']}.sort).to_not include stance.participant.id
    end
  end

  describe 'history' do
    let(:event) { create :event, kind: 'announcement_created', eventable: group, user: group.creator}
    let!(:notifications) { create :notification, event: event, user: user }

    it 'responds with event history' do
      sign_in user
      get :history, params: {group_id: group.id}
      expect(response.status).to eq 200
      puts response.body
      # expect(JSON.parse response.body)

    end
  end

  describe 'create' do
    let(:notified_user) { create :user }
    let(:member) { create :user }

    describe 'discussion' do
      before do
        discussion.group.add_member! member
      end

      let(:discussion)    { create :discussion, author: user }

      it 'cannot announce unless members_can_announce' do
        discussion.group.update(members_can_announce: false)
        sign_in member
        recipients = {user_ids: [notified_user.id], emails: []}
        post :create, params: {discussion_id: discussion.id,
                               announcement: {kind: "new_discussion", recipients: recipients}}
        expect(response.status).to eq 403
      end

      it 'can announce if members_can_announce' do
        discussion.group.update(members_can_announce: true)
        sign_in member
        recipients = {user_ids: [notified_user.id], emails: []}
        post :create, params: {discussion_id: discussion.id,
                               announcement: {kind: "new_discussion", recipients: recipients}}
        expect(response.status).to eq 200
      end

      it 'notify exising user' do
        recipients = {user_ids: [notified_user.id], emails: []}
        post :create, params: {discussion_id: discussion.id,
                               announcement: {kind: "new_discussion", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        expect(notified_user.notifications.count).to eq 1
        expect(discussion.guest_group.members).to include notified_user
      end

      it 'notify new user by email' do
        recipients = {user_ids: [], emails: ['jim@example.com']}
        post :create, params: {discussion_id: discussion.id,
                               announcement: {kind: "new_discussion", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        email_user = User.find_by(email: "jim@example.com")
        expect(email_user.notifications.count).to eq 1
        expect(email_user.email_verified).to be false
        expect(email_user.memberships.pending.count).to eq 1
        expect(discussion.guest_group.members).to include email_user
      end

      it 'notify existing user by email' do
        recipients = {user_ids: [], emails: [notified_user.email]}
        post :create, params: {discussion_id: discussion.id,
                               announcement: {kind: "new_discussion", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        expect(User.where(email: notified_user.email).count).to eq 1
        expect(notified_user.groups).to include discussion.guest_group
      end
    end

    describe 'poll' do
      let(:poll)          { create :poll, author: user }

      it 'does not permit non author to announce' do
        sign_in create(:user)
        recipients = {user_ids: [notified_user.id], emails: []}
        post :create, params: {poll_id: poll.id,
                               announcement: {kind: "poll_created", recipients: recipients}}
        expect(response.status).to eq 403
      end

      it 'notify exising user' do
        recipients = {user_ids: [notified_user.id], emails: []}
        post :create, params: {poll_id: poll.id,
                               announcement: {kind: "poll_created", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        expect(notified_user.notifications.count).to eq 1
        expect(poll.guest_group.members).to include notified_user
      end

      it 'notify new user by email' do
        recipients = {user_ids: [], emails: ['jim@example.com']}
        post :create, params: {poll_id: poll.id,
                               announcement: {kind: "poll_created", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        email_user = User.find_by(email: "jim@example.com")
        expect(email_user.notifications.count).to eq 1
        expect(email_user.email_verified).to be false
        expect(email_user.memberships.pending.count).to eq 1
        expect(poll.guest_group.members).to include email_user
      end

      it 'notify existing user by email' do
        recipients = {user_ids: [], emails: [notified_user.email]}
        post :create, params: {poll_id: poll.id,
                               announcement: {kind: "poll_created", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        expect(User.where(email: notified_user.email).count).to eq 1
        expect(notified_user.groups).to include poll.guest_group
      end
    end

    describe 'outcome' do
      let(:poll)    { create :poll, author: user, closed_at: 1.day.ago }
      let(:outcome) { create :outcome, author: user, poll: poll }

      it 'does not permit non author to announce' do
        sign_in create(:user)
        recipients = {user_ids: [notified_user.id], emails: []}
        post :create, params: {outcome_id: outcome.id,
                               announcement: {kind: "outcome_created", recipients: recipients}}
        expect(response.status).to eq 403
      end

      it 'notify exising user' do
        recipients = {user_ids: [notified_user.id], emails: []}
        post :create, params: {outcome_id: outcome.id,
                               announcement: {kind: "outcome_created", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        expect(notified_user.notifications.count).to eq 1
        expect(outcome.guest_group.members).to include notified_user
      end

      it 'notify new user by email' do
        recipients = {user_ids: [], emails: ['jim@example.com']}
        post :create, params: {outcome_id: outcome.id,
                               announcement: {kind: "outcome_created", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        email_user = User.find_by(email: "jim@example.com")
        expect(email_user.notifications.count).to eq 1
        expect(email_user.email_verified).to be false
        expect(email_user.memberships.pending.count).to eq 1
        expect(outcome.guest_group.members).to include email_user
      end

      it 'notify existing user by email' do
        recipients = {user_ids: [], emails: [notified_user.email]}
        post :create, params: {outcome_id: outcome.id,
                               announcement: {kind: "outcome_created", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        expect(User.where(email: notified_user.email).count).to eq 1
        expect(notified_user.groups).to include outcome.guest_group
      end
    end

    describe 'group' do
      let(:group) { create :formal_group, creator: user}

      it 'does not permit non author to announce' do
        sign_in create(:user)
        recipients = {user_ids: [notified_user.id], emails: []}
        post :create, params: {group_id: group.id,
                               announcement: {kind: "group_announced", recipients: recipients}}
        expect(response.status).to eq 403
      end

      it 'notify exising user' do
        recipients = {user_ids: [notified_user.id], emails: []}
        post :create, params: {group_id: group.id,
                               announcement: {kind: "group_announced", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        expect(notified_user.notifications.count).to eq 1
        expect(group.members).to include notified_user
      end

      it 'notify new user by email' do
        recipients = {user_ids: [], emails: ['jim@example.com']}
        post :create, params: {group_id: group.id,
                               announcement: {kind: "group_announced", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        email_user = User.find_by(email: "jim@example.com")
        expect(email_user.notifications.count).to eq 1
        expect(email_user.email_verified).to be false
        expect(email_user.memberships.pending.count).to eq 1
        expect(group.members).to include email_user
      end

      it 'notify existing user by email' do
        recipients = {user_ids: [], emails: [notified_user.email]}
        post :create, params: {group_id: group.id,
                               announcement: {kind: "group_announced", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        expect(User.where(email: notified_user.email).count).to eq 1
        expect(notified_user.groups).to include group.guest_group
      end

      it 'does not allow announcement if max members is reached' do
        AppConfig.app_features[:subscription] = true
        Subscription.for(group).update(max_members: 0)
        recipients = {user_ids: [], emails: ['jim@example.com']}
        post :create, params: {group_id: group.id,
                               announcement: {kind: "group_announced", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 403
      end
    end
  end
end
