require 'rails_helper'

describe API::AnnouncementsController do
  let (:user) { create :user }
  let(:another_user) { create :user }
  let(:a_third_user) { create :user }
  let(:a_fourth_user) { create :user }
  let(:group) { create :formal_group }
  let(:group_notified) {{
    id: group.id,
    type: "Group",
    notified_ids: [another_user.id, a_third_user.id]
  }}
  let(:user_notified) {{
    id: a_fourth_user.id,
    type: "User",
    notified_ids: [a_fourth_user.id]
  }}
  let(:email_notified) {{
    id: "test@example.com",
    type: "Invitation",
    notified_ids: []
  }}

  before do
    group.add_admin! user
    group.add_member! another_user
    group.add_member! a_third_user
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

  describe 'bulk_create' do
    it 'creates announcement_created records'
    it 'creates users by email'
    it 'adds existing users to the models guest group'
    it 'adds created users to the models guest group'

    it 'sends a notification to an existing user'
    it 'sends a notification to a created user'
    it 'does send an email to a user with email_when_announced true'
    it 'does not send an email to a user with email_when_announced false'
  end

  describe 'create' do
    describe 'poll' do
      let(:poll) { create :poll, group: group, author: user }
      let(:poll_created_event) { poll.created_event }
      let(:announcement_params) {{ event_id: poll_created_event.id }}
      let(:eventless_announcement_params) {{ model_id: poll.id, model_type: "Poll" }}
      let(:bad_announcement_params) {{ event_id: nil }}

      it 'creates an announcement to all notified types' do
        announcement_params[:notified] = [group_notified, user_notified, email_notified]
        expect { post :create, params: { announcement: announcement_params } }.to change { Announcement.count }.by(1)
        expect(response.status).to eq 200
        a = Announcement.last
        expect(poll.reload.announcements_count).to eq 1
        expect(a.users_to_announce).to include another_user
        expect(a.users_to_announce).to include a_third_user
        expect(a.users_to_announce).to include a_fourth_user
        expect(a.invitations.pluck(:recipient_email)).to include email_notified[:id]

        expect(another_user.can?(:show, poll)).to eq true
        expect(a_third_user.can?(:show, poll)).to eq true
        expect(a_fourth_user.can?(:show, poll)).to eq true
        expect(another_user.can?(:vote_in, poll)).to eq true
        expect(a_third_user.can?(:vote_in, poll)).to eq true
        expect(a_fourth_user.can?(:vote_in, poll)).to eq true
      end

      it 'soft creates a poll_announced event if none is given' do
        eventless_announcement_params[:notified] = [group_notified, user_notified, email_notified]
        expect { post :create, params: { announcement: eventless_announcement_params } }.to change { Announcement.count }.by(1)
        expect(response.status).to eq 200
        poll_announced = Event.find_by(kind: :poll_announced)
        expect(poll_announced).to be_present
        expect(poll_announced.eventable).to eq poll

        a = Announcement.last
        expect(a.event).to eq poll_announced
        expect(poll.reload.announcements_count).to eq 1
      end

      it 'announces to a group' do
        announcement_params[:notified] = [group_notified]
        expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(2)
        a = Announcement.last
        expect(a.users_to_announce).to include another_user
        expect(a.users_to_announce).to include a_third_user
        expect(a.users_to_announce).to_not include a_fourth_user
        expect(a.invitations).to be_empty
      end

      it 'announces to an individual user' do
        announcement_params[:notified] = [user_notified]
        expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(1)
        a = Announcement.last
        expect(poll.guest_group.members).to include a_fourth_user
        expect(poll.group.members).to_not include a_fourth_user
        expect(a.users_to_announce).to include a_fourth_user
        expect(a.users_to_announce).to_not include another_user
        expect(a.invitations).to be_empty
      end

      it 'announces to an email address' do
        announcement_params[:notified] = [email_notified]
        expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(1)
        a = Announcement.last
        expect(poll.guest_group.invitation_ids).to eq a.invitation_ids
        expect(a.users_to_announce).to be_empty
        expect(a.invitations.pluck(:recipient_email)).to eq [email_notified[:id]]
        expect(a.invitations.pluck(:intent)).to eq ['join_poll']
      end

      it 'does not announce the same user twice' do
        announcement_params[:notified] = [user_notified, user_notified]
        expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(Announcement.last.users.count).to eq 1
      end

      it 'does not announce the same email twice' do
        announcement_params[:notified] = [email_notified, email_notified]
        expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(Announcement.last.invitations.count).to eq 1
      end

      it 'does not allow announcements by unauthorized users' do
        announcement_params[:event_id] = create(:poll).created_event.id
        expect { post :create, params: { announcement: announcement_params } }.to_not change { ActionMailer::Base.deliveries.count }
        expect(response.status).to eq 403
      end
    end

    describe 'outcome' do
      let(:outcome) { create :outcome, poll: poll, author: user }
      let(:poll) { create :poll, author: user, closed_at: 1.day.ago }
      let(:outcome_created) { outcome.created_event }
      let(:eventless_announcement_params) {{ model_id: outcome.id, model_type: "Outcome" }}
      let(:announcement_params) {{ event_id: outcome_created.id }}

      it 'creates an announcement  to all notified types' do
        announcement_params[:notified] = [group_notified, user_notified, email_notified]
        expect { post :create, params: { announcement: announcement_params } }.to change { Announcement.count }.by(1)
        expect(response.status).to eq 200
        a = Announcement.last
        expect(outcome.reload.announcements_count).to eq 1
        expect(a.users_to_announce).to include another_user
        expect(a.users_to_announce).to include a_third_user
        expect(a.users_to_announce).to include a_fourth_user
        expect(a.invitations.pluck(:recipient_email)).to include email_notified[:id]
        expect(a.invitations.pluck(:intent)).to eq ['join_outcome']

        expect(another_user.can?(:show, outcome)).to eq true
        expect(a_third_user.can?(:show, outcome)).to eq true
        expect(a_fourth_user.can?(:show, outcome)).to eq true
      end

      it 'soft creates an outcome_announced event if none is given' do
        eventless_announcement_params[:notified] = [group_notified, user_notified, email_notified]
        expect { post :create, params: { announcement: eventless_announcement_params } }.to change { Announcement.count }.by(1)
        expect(response.status).to eq 200
        outcome_announced = Event.find_by(kind: :outcome_announced)
        expect(outcome_announced).to be_present
        expect(outcome_announced.eventable).to eq outcome

        a = Announcement.last
        expect(a.event).to eq outcome_announced
        expect(outcome.reload.announcements_count).to eq 1
      end
    end

    describe 'discussion' do
      let(:discussion) { create :discussion, group: group, author: user }
      let(:discussion_created) { discussion.created_event }
      let(:eventless_announcement_params) {{ model_id: discussion.id, model_type: "Discussion" }}
      let(:announcement_params) {{ event_id: discussion_created.id }}

      it 'creates an announcement to all notified types' do
        announcement_params[:notified] = [group_notified, user_notified, email_notified]
        expect { post :create, params: { announcement: announcement_params } }.to change { Announcement.count }.by(1)
        expect(response.status).to eq 200
        a = Announcement.last
        expect(discussion.reload.announcements_count).to eq 1
        expect(a.users_to_announce).to include another_user
        expect(a.users_to_announce).to include a_third_user
        expect(a.users_to_announce).to include a_fourth_user
        expect(a.invitations.pluck(:recipient_email)).to include email_notified[:id]

        expect(another_user.can?(:show, discussion)).to eq true
        expect(a_third_user.can?(:show, discussion)).to eq true
        expect(a_fourth_user.can?(:show, discussion)).to eq true
      end

      it 'soft creates a discussion_announced event if none is given' do
        eventless_announcement_params[:notified] = [group_notified, user_notified, email_notified]
        expect { post :create, params: { announcement: eventless_announcement_params } }.to change { Announcement.count }.by(1)
        expect(response.status).to eq 200
        discussion_announced = Event.find_by(kind: :discussion_announced)
        expect(discussion_announced).to be_present
        expect(discussion_announced.eventable).to eq discussion

        a = Announcement.last
        expect(a.event).to eq discussion_announced
        expect(discussion.reload.announcements_count).to eq 1
      end

      it 'announces to a group' do
        announcement_params[:notified] = [group_notified]
        expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(2)
        a = Announcement.last
        expect(discussion.reload.group.members).to include another_user
        expect(discussion.reload.guest_group.members).to_not include another_user
        expect(a.users_to_announce).to include another_user
        expect(a.users_to_announce).to include a_third_user
        expect(a.users_to_announce).to_not include a_fourth_user
        expect(a.invitations).to be_empty
      end

      it 'announces to an individual user' do
        announcement_params[:notified] = [user_notified]
        expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(1)
        a = Announcement.last
        expect(discussion.reload.guest_group.members).to include a_fourth_user
        expect(discussion.reload.group.members).to_not include a_fourth_user
        expect(a.users_to_announce).to include a_fourth_user
        expect(a.users_to_announce).to_not include another_user
        expect(a.invitations).to be_empty
      end

      it 'announces to an email address' do
        announcement_params[:notified] = [email_notified]
        expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(1)
        a = Announcement.last
        expect(discussion.reload.guest_group.invitation_ids).to eq a.invitation_ids
        expect(a.users_to_announce).to be_empty
        expect(a.invitations.pluck(:recipient_email)).to eq [email_notified[:id]]
        expect(a.invitations.pluck(:intent)).to eq ['join_discussion']
      end

      it 'does not announce the same user twice' do
        announcement_params[:notified] = [user_notified, user_notified]
        expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(Announcement.last.users.count).to eq 1
      end

      it 'does not announce the same email twice' do
        announcement_params[:notified] = [email_notified, email_notified]
        expect { post :create, params: { announcement: announcement_params } }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(Announcement.last.invitations.count).to eq 1
      end

      it 'does not allow announcements by unauthorized users' do
        announcement_params[:event_id] = create(:discussion).created_event.id
        expect { post :create, params: { announcement: announcement_params } }.to_not change { ActionMailer::Base.deliveries.count }
        expect(response.status).to eq 403
      end
    end
  end

  describe 'notified_default' do
    let(:discussion) { create :discussion, group: group }
    let(:poll) { create :poll_proposal, discussion: discussion }
    let(:outcome) { create :outcome, poll: poll }

    it 'gives back the group members for a poll_created event' do
      get :notified_default, params: { kind: :poll_created, poll_id: poll.id }
      json = JSON.parse(response.body)
      expect(json.length).to eq 1
      expect(json[0]['notified_ids']).to include another_user.id
      expect(json[0]['notified_ids']).to_not include a_fourth_user.id
      expect(json[0]['notified_ids']).to_not include user.id
    end

    it 'gives back the poll participants for a poll_edited event' do
      Stance.create!(poll: poll, participant: user, choice: :agree)
      Stance.create!(poll: poll, participant: a_fourth_user, choice: :agree)

      get :notified_default, params: { kind: :poll_edited, poll_id: poll.id }
      json = JSON.parse(response.body)
      expect(json.length).to eq 1
      expect(json[0]['notified_ids']).to_not include another_user.id
      expect(json[0]['notified_ids']).to include a_fourth_user.id
      expect(json[0]['notified_ids']).to_not include user.id
    end

    it 'gives back the poll participants for a poll_option_added event' do
      Stance.create!(poll: poll, participant: user, choice: :agree)
      Stance.create!(poll: poll, participant: a_fourth_user, choice: :agree)

      get :notified_default, params: { kind: :poll_option_added, poll_id: poll.id }
      json = JSON.parse(response.body)
      expect(json.length).to eq 1
      expect(json[0]['notified_ids']).to_not include another_user.id
      expect(json[0]['notified_ids']).to include a_fourth_user.id
      expect(json[0]['notified_ids']).to_not include user.id
    end

    it 'gives back the group members for a new_discussion event' do
      get :notified_default, params: { kind: :new_discussion, discussion_id: discussion.id }
      json = JSON.parse(response.body)
      expect(json.length).to eq 1
      expect(json[0]['notified_ids']).to include another_user.id
      expect(json[0]['notified_ids']).to_not include a_fourth_user.id
      expect(json[0]['notified_ids']).to_not include user.id
    end

    it 'gives back the group members for a discussion_edited event' do
      get :notified_default, params: { kind: :discussion_edited, discussion_id: discussion.id }
      json = JSON.parse(response.body)
      expect(json.length).to eq 1
      expect(json[0]['notified_ids']).to include another_user.id
      expect(json[0]['notified_ids']).to_not include a_fourth_user.id
      expect(json[0]['notified_ids']).to_not include user.id
    end

    it 'gives back the group members for a outcome_created event' do
      get :notified_default, params: { kind: :outcome_created, outcome_id: outcome.id }
      json = JSON.parse(response.body)
      expect(json.length).to eq 1
      expect(json[0]['notified_ids']).to include another_user.id
      expect(json[0]['notified_ids']).to_not include a_fourth_user.id
      expect(json[0]['notified_ids']).to_not include user.id
    end

    it 'returns nothing when a model is not part of a group' do
      poll.update(discussion: nil, group: nil, anyone_can_participate: true)
      get :notified_default, params: { kind: :poll_created, poll_id: poll.id }
      json = JSON.parse(response.body)
      expect(json.length).to eq 0
    end

    it 'does not allow wrong kinds' do
      get :notified_default, params: { kind: :discussion_moved, discussion_id: discussion.id }
      expect(response.status).to eq 404
    end

    it 'does not allow unauthorized users access' do
      get :notified_default, params: { kind: :poll_created, poll_id: create(:poll).id }
      expect(response.status).to eq 403
    end

    it '404s on unfound models' do
      get :notified_default, params: { kind: :poll_created, poll_id: -1 }
      expect(response.status).to eq 404
    end
  end
end
