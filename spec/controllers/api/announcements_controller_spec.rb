require 'rails_helper'

describe API::AnnouncementsController do
  let(:user)  { create :user }
  let(:group) { create :formal_group }

  before do
    group.add_admin! user
    sign_in user
  end

  describe 'audience' do
    let(:group)      { create :formal_group }
    let(:discussion) { create :discussion, group: group }

    it 'formal_group' do
      get :audience, params: {discussion_id: discussion.id, kind: "formal_group"}
      json = JSON.parse response.body
      expect(json.map {|u| u['id']}.sort).to eq group.member_ids.sort
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

  describe 'create' do
    let(:notified_user) { create :user }

    describe 'discussion' do
      let(:discussion)    { create :discussion, author: user }

      it 'does not permit non author to announce' do
        sign_in create(:user)
        recipients = {user_ids: [notified_user.id], emails: []}
        post :create, params: {discussion_id: discussion.id,
                               announcement: {kind: "new_discussion", recipients: recipients}}
        expect(response.status).to eq 403
      end

      it 'notify exising user' do
        recipients = {user_ids: [notified_user.id], emails: []}
        post :create, params: {discussion_id: discussion.id,
                               announcement: {kind: "new_discussion", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        expect(json['users_count']).to eq 1
        expect(notified_user.notifications.count).to eq 1
        expect(discussion.guest_group.members).to include notified_user
      end

      it 'notify new user by email' do
        recipients = {user_ids: [], emails: ['jim@example.com']}
        post :create, params: {discussion_id: discussion.id,
                               announcement: {kind: "new_discussion", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        expect(json['users_count']).to eq 1
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
        expect(json['users_count']).to eq 1
        expect(User.where(email: notified_user.email).count).to eq 2
        expect(notified_user.groups).to_not include discussion.guest_group
      end
    end

    describe 'poll' do
      let(:poll)          { create :poll, author: user }

      it 'does not permit non author to announce' do
        sign_in create(:user)
        recipients = {user_ids: [notified_user.id], emails: []}
        post :create, params: {poll_id: poll.id,
                               announcement: {kind: "new_poll", recipients: recipients}}
        expect(response.status).to eq 403
      end

      it 'notify exising user' do
        recipients = {user_ids: [notified_user.id], emails: []}
        post :create, params: {poll_id: poll.id,
                               announcement: {kind: "new_poll", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        expect(json['users_count']).to eq 1
        expect(notified_user.notifications.count).to eq 1
        expect(poll.guest_group.members).to include notified_user
      end

      it 'notify new user by email' do
        recipients = {user_ids: [], emails: ['jim@example.com']}
        post :create, params: {poll_id: poll.id,
                               announcement: {kind: "new_poll", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        expect(json['users_count']).to eq 1
        email_user = User.find_by(email: "jim@example.com")
        expect(email_user.notifications.count).to eq 1
        expect(email_user.email_verified).to be false
        expect(email_user.memberships.pending.count).to eq 1
        expect(poll.guest_group.members).to include email_user
      end

      it 'notify existing user by email' do
        recipients = {user_ids: [], emails: [notified_user.email]}
        post :create, params: {poll_id: poll.id,
                               announcement: {kind: "new_poll", recipients: recipients}}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        expect(json['users_count']).to eq 1
        expect(User.where(email: notified_user.email).count).to eq 2
        expect(notified_user.groups).to_not include poll.guest_group
      end
    end

    describe 'outcome' do
    end

    # describe 'group' do
    # end
  end

  # describe 'create' do
  #   describe 'poll' do
  #     let(:poll) { create :poll, group: group, author: user }
  #     let(:poll_created_event) { poll.created_event }
  #     let(:announcement_params) {{ event_id: poll_created_event.id }}
  #     let(:eventless_announcement_params) {{ model_id: poll.id, model_type: "Poll" }}
  #     let(:bad_announcement_params) {{ event_id: nil }}
  #
  #     it 'creates an announcement to all notified types' do
  #       announcement_params[:notified] = [group_notified, user_notified, email_notified]
  #       expect { post :create, params: { announcement: announcement_params } }.to change { Announcement.count }.by(1)
  #       expect(response.status).to eq 200
  #       a = Announcement.last
  #       expect(poll.reload.announcements_count).to eq 1
  #       expect(a.users_to_announce).to include another_user
  #       expect(a.users_to_announce).to include a_third_user
  #       expect(a.users_to_announce).to include a_fourth_user
  #       expect(a.invitations.pluck(:recipient_email)).to include email_notified[:id]
  #
  #       expect(another_user.can?(:show, poll)).to eq true
  #       expect(a_third_user.can?(:show, poll)).to eq true
  #       expect(a_fourth_user.can?(:show, poll)).to eq true
  #       expect(another_user.can?(:vote_in, poll)).to eq true
  #       expect(a_third_user.can?(:vote_in, poll)).to eq true
  #       expect(a_fourth_user.can?(:vote_in, poll)).to eq true
  #     end
  #
  #     it 'soft creates a poll_announced event if none is given' do
  #       eventless_announcement_params[:notified] = [group_notified, user_notified, email_notified]
  #       expect { post :create, params: { announcement: eventless_announcement_params } }.to change { Announcement.count }.by(1)
  #       expect(response.status).to eq 200
  #       poll_announced = Event.find_by(kind: :poll_announced)
  #       expect(poll_announced).to be_present
  #       expect(poll_announced.eventable).to eq poll
  #
  #       a = Announcement.last
  #       expect(a.event).to eq poll_announced
  #       expect(poll.reload.announcements_count).to eq 1
  #     end
  #
  #     it 'announces to a group' do
  #       announcement_params[:notified] = [group_notified]
  #       expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(2)
  #       a = Announcement.last
  #       expect(a.users_to_announce).to include another_user
  #       expect(a.users_to_announce).to include a_third_user
  #       expect(a.users_to_announce).to_not include a_fourth_user
  #       expect(a.invitations).to be_empty
  #     end
  #
  #     it 'announces to an individual user' do
  #       announcement_params[:notified] = [user_notified]
  #       expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(1)
  #       a = Announcement.last
  #       expect(poll.guest_group.members).to include a_fourth_user
  #       expect(poll.group.members).to_not include a_fourth_user
  #       expect(a.users_to_announce).to include a_fourth_user
  #       expect(a.users_to_announce).to_not include another_user
  #       expect(a.invitations).to be_empty
  #     end
  #
  #     it 'announces to an email address' do
  #       announcement_params[:notified] = [email_notified]
  #       expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(1)
  #       a = Announcement.last
  #       expect(poll.guest_group.invitation_ids).to eq a.invitation_ids
  #       expect(a.users_to_announce).to be_empty
  #       expect(a.invitations.pluck(:recipient_email)).to eq [email_notified[:id]]
  #       expect(a.invitations.pluck(:intent)).to eq ['join_poll']
  #     end
  #
  #     it 'does not announce the same user twice' do
  #       announcement_params[:notified] = [user_notified, user_notified]
  #       expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(1)
  #       expect(Announcement.last.users.count).to eq 1
  #     end
  #
  #     it 'does not announce the same email twice' do
  #       announcement_params[:notified] = [email_notified, email_notified]
  #       expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(1)
  #       expect(Announcement.last.invitations.count).to eq 1
  #     end
  #
  #     it 'does not allow announcements by unauthorized users' do
  #       announcement_params[:event_id] = create(:poll).created_event.id
  #       expect { post :create, params: { announcement: announcement_params } }.to_not change { ActionMailer::Base.deliveries.count }
  #       expect(response.status).to eq 403
  #     end
  #   end
  #
  #   describe 'outcome' do
  #     let(:outcome) { create :outcome, poll: poll, author: user }
  #     let(:poll) { create :poll, author: user, closed_at: 1.day.ago }
  #     let(:outcome_created) { outcome.created_event }
  #     let(:eventless_announcement_params) {{ model_id: outcome.id, model_type: "Outcome" }}
  #     let(:announcement_params) {{ event_id: outcome_created.id }}
  #
  #     it 'creates an announcement  to all notified types' do
  #       announcement_params[:notified] = [group_notified, user_notified, email_notified]
  #       expect { post :create, params: { announcement: announcement_params } }.to change { Announcement.count }.by(1)
  #       expect(response.status).to eq 200
  #       a = Announcement.last
  #       expect(outcome.reload.announcements_count).to eq 1
  #       expect(a.users_to_announce).to include another_user
  #       expect(a.users_to_announce).to include a_third_user
  #       expect(a.users_to_announce).to include a_fourth_user
  #       expect(a.invitations.pluck(:recipient_email)).to include email_notified[:id]
  #       expect(a.invitations.pluck(:intent)).to eq ['join_outcome']
  #
  #       expect(another_user.can?(:show, outcome)).to eq true
  #       expect(a_third_user.can?(:show, outcome)).to eq true
  #       expect(a_fourth_user.can?(:show, outcome)).to eq true
  #     end
  #
  #     it 'soft creates an outcome_announced event if none is given' do
  #       eventless_announcement_params[:notified] = [group_notified, user_notified, email_notified]
  #       expect { post :create, params: { announcement: eventless_announcement_params } }.to change { Announcement.count }.by(1)
  #       expect(response.status).to eq 200
  #       outcome_announced = Event.find_by(kind: :outcome_announced)
  #       expect(outcome_announced).to be_present
  #       expect(outcome_announced.eventable).to eq outcome
  #
  #       a = Announcement.last
  #       expect(a.event).to eq outcome_announced
  #       expect(outcome.reload.announcements_count).to eq 1
  #     end
  #   end
  #
  #   describe 'discussion' do
  #     let(:discussion) { create :discussion, group: group, author: user }
  #     let(:discussion_created) { discussion.created_event }
  #     let(:eventless_announcement_params) {{ model_id: discussion.id, model_type: "Discussion" }}
  #     let(:announcement_params) {{ event_id: discussion_created.id }}
  #
  #     it 'creates an announcement to all notified types' do
  #       announcement_params[:notified] = [group_notified, user_notified, email_notified]
  #       expect { post :create, params: { announcement: announcement_params } }.to change { Announcement.count }.by(1)
  #       expect(response.status).to eq 200
  #       a = Announcement.last
  #       expect(discussion.reload.announcements_count).to eq 1
  #       expect(a.users_to_announce).to include another_user
  #       expect(a.users_to_announce).to include a_third_user
  #       expect(a.users_to_announce).to include a_fourth_user
  #       expect(a.invitations.pluck(:recipient_email)).to include email_notified[:id]
  #
  #       expect(another_user.can?(:show, discussion)).to eq true
  #       expect(a_third_user.can?(:show, discussion)).to eq true
  #       expect(a_fourth_user.can?(:show, discussion)).to eq true
  #     end
  #
  #     it 'soft creates a discussion_announced event if none is given' do
  #       eventless_announcement_params[:notified] = [group_notified, user_notified, email_notified]
  #       expect { post :create, params: { announcement: eventless_announcement_params } }.to change { Announcement.count }.by(1)
  #       expect(response.status).to eq 200
  #       discussion_announced = Event.find_by(kind: :discussion_announced)
  #       expect(discussion_announced).to be_present
  #       expect(discussion_announced.eventable).to eq discussion
  #
  #       a = Announcement.last
  #       expect(a.event).to eq discussion_announced
  #       expect(discussion.reload.announcements_count).to eq 1
  #     end
  #
  #     it 'announces to a group' do
  #       announcement_params[:notified] = [group_notified]
  #       expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(2)
  #       a = Announcement.last
  #       expect(discussion.reload.group.members).to include another_user
  #       expect(discussion.reload.guest_group.members).to_not include another_user
  #       expect(a.users_to_announce).to include another_user
  #       expect(a.users_to_announce).to include a_third_user
  #       expect(a.users_to_announce).to_not include a_fourth_user
  #       expect(a.invitations).to be_empty
  #     end
  #
  #     it 'announces to an individual user' do
  #       announcement_params[:notified] = [user_notified]
  #       expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(1)
  #       a = Announcement.last
  #       expect(discussion.reload.guest_group.members).to include a_fourth_user
  #       expect(discussion.reload.group.members).to_not include a_fourth_user
  #       expect(a.users_to_announce).to include a_fourth_user
  #       expect(a.users_to_announce).to_not include another_user
  #       expect(a.invitations).to be_empty
  #     end
  #
  #     it 'announces to an email address' do
  #       announcement_params[:notified] = [email_notified]
  #       expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(1)
  #       a = Announcement.last
  #       expect(discussion.reload.guest_group.invitation_ids).to eq a.invitation_ids
  #       expect(a.users_to_announce).to be_empty
  #       expect(a.invitations.pluck(:recipient_email)).to eq [email_notified[:id]]
  #       expect(a.invitations.pluck(:intent)).to eq ['join_discussion']
  #     end
  #
  #     it 'does not announce the same user twice' do
  #       announcement_params[:notified] = [user_notified, user_notified]
  #       expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(1)
  #       expect(Announcement.last.users.count).to eq 1
  #     end
  #
  #     it 'does not announce the same email twice' do
  #       announcement_params[:notified] = [email_notified, email_notified]
  #       expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(1)
  #       expect(Announcement.last.invitations.count).to eq 1
  #     end
  #
  #     it 'does not allow announcements by unauthorized users' do
  #       announcement_params[:event_id] = create(:discussion).created_event.id
  #       expect { post :create, params: { announcement: announcement_params } }.to_not change { ActionMailer::Base.deliveries.count }
  #       expect(response.status).to eq 403
  #     end
  #   end
  # end
end
