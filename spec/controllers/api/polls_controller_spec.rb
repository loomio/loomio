require 'rails_helper'

describe API::PollsController do
  let(:group) { create :group }
  let(:another_group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:another_discussion) { create :discussion, group: group }
  let(:non_group_discussion) { create :discussion }
  let(:user) { create :user }
  let(:another_user) { create :user }
  let!(:poll) { create :poll, title: "POLL!", discussion: discussion, author: user }
  let(:another_poll) { create :poll, title: "ANOTHER", discussion: another_discussion }
  let(:closed_poll) { create :poll, title: "CLOSED", author: user, closed_at: 1.day.ago }
  let(:non_group_poll) { create :poll }
  let(:poll_params) {{
    title: "hello",
    poll_type: "proposal",
    details: "is it me you're looking for?",
    discussion_id: discussion.id,
    poll_option_names: ["agree", "abstain", "disagree", "block"],
    closing_at: 3.days.from_now
  }}

  before { group.add_member! user }

  describe 'show' do
    it 'shows a poll' do
      sign_in user
      get :show, params: { id: poll.key }
      json = JSON.parse(response.body)
      expect(json['polls'].length).to eq 1
      expect(json['polls'][0]['key']).to eq poll.key
    end

    it 'does not show a poll you do not have access to' do
      sign_in another_user
      get :show, params: { id: poll.key }
      expect(response.status).to eq 403
    end
  end

  describe 'index' do
    before { poll; another_poll; closed_poll }

    let(:participated_poll) { create :poll }
    let!(:my_stance) { create :stance, poll: participated_poll, participant: user, poll_options: [participated_poll.poll_options.first] }
    let!(:authored_poll) { create :poll, author: user }
    let!(:group_poll) { create :poll, discussion: discussion }
    let!(:another_poll) { create :poll }

    it 'shows polls in a discussion' do
      sign_in user
      get :index, params: { discussion_key: discussion.key }
      json = JSON.parse(response.body)
      poll_keys = json['polls'].map { |p| p['key'] }
      expect(poll_keys).to include poll.key
      expect(poll_keys).to_not include another_poll.key
      expect(poll_keys).to_not include non_group_poll.key
    end

    it 'does not allow user to see polls theyre not allowed to see' do
      sign_in user
      get :index, params: { discussion_key: non_group_discussion.key }
      json = JSON.parse(response.body)
      expect(json['polls'].length).to eq 0
    end

    describe 'signed in' do
      before { sign_in user }

      it 'returns visible polls' do
        get :index
        json = JSON.parse(response.body)
        poll_ids = json['polls'].map { |p| p['id'] }

        expect(poll_ids).to include participated_poll.id
        expect(poll_ids).to include authored_poll.id
        expect(poll_ids).to include group_poll.id
        expect(poll_ids).to_not include another_poll.id
      end

      it 'filters by status' do
        authored_poll.update(closed_at: 1.day.ago)
        get :index, params: { status: :closed }

        json = JSON.parse(response.body)
        poll_ids = json['polls'].map { |p| p['id'] }

        # expect(poll_ids).to include authored_poll.id
        expect(poll_ids).to_not include participated_poll.id
        expect(poll_ids).to_not include group_poll.id
        expect(poll_ids).to_not include another_poll.id
      end

      it 'filters by group' do
        get :index, params: { group_key: group.key }
        json = JSON.parse(response.body)
        poll_ids = json['polls'].map { |p| p['id'] }

        expect(poll_ids).to include group_poll.id
        expect(poll_ids).to_not include participated_poll.id
        expect(poll_ids).to_not include authored_poll.id
        expect(poll_ids).to_not include another_poll.id
      end

      it 'filters by discussion' do
        get :index, params: { discussion_key: discussion.key }
        json = JSON.parse(response.body)
        poll_ids = json['polls'].map { |p| p['id'] }

        expect(poll_ids).to include group_poll.id
        expect(poll_ids).to_not include participated_poll.id
        expect(poll_ids).to_not include authored_poll.id
        expect(poll_ids).to_not include another_poll.id
      end

      it 'filters by authored' do
        get :index, params: { author_id: authored_poll.author_id}
        json = JSON.parse(response.body)
        poll_ids = json['polls'].map { |p| p['id'] }

        expect(poll_ids).to include authored_poll.id
        expect(poll_ids).to_not include participated_poll.id
        expect(poll_ids).to_not include group_poll.id
        expect(poll_ids).to_not include another_poll.id
      end

      it 'filters by search fragment' do
        authored_poll.update(title: "Made in Korea!")
        get :index, params: { query: "Korea" }
        json = JSON.parse(response.body)
        poll_ids = json['polls'].map { |p| p['id'] }

        expect(poll_ids).to include authored_poll.id
        expect(poll_ids).to_not include group_poll.id
        expect(poll_ids).to_not include participated_poll.id
        expect(poll_ids).to_not include another_poll.id
      end

      describe 'discard' do
        let(:poll) { build :poll }
        context 'allowed to discard' do
          it 'discards the poll' do
            PollService.create(poll: poll, actor: user)
            delete :discard, params: { id: poll.id }
            expect(response.status).to eq 200
            poll.reload
            expect(poll.discarded?).to be true
            expect(poll.discarded_by).to eq user.id
            expect(poll.created_event.reload.user_id).to be nil
          end
        end

        context 'not allowed to discard' do
          it 'discards the poll' do
            sign_in another_user
            PollService.create(poll: poll, actor: user)
            delete :discard, params: { id: poll.id }
            expect(response.status).to eq 403
            poll.reload
            expect(poll.discarded?).to be false
            expect(poll.created_event.user_id).to_not be nil
          end
        end
      end

    end
  end

  describe 'create' do
    before do
      sign_in user
    end

    let(:identity) { create :slack_identity, user: user }
    let(:community) { create :slack_community, identity: identity }
    let(:another_identity) { create :slack_identity }
    let(:another_community) { create :slack_community, identity: another_identity }

    it 'creates a poll' do
      expect { post :create, params: { poll: poll_params } }.to change { Poll.count }.by(1)
      expect(response.status).to eq 200

      poll = Poll.last
      expect(poll.title).to eq poll_params[:title]
      expect(poll.discussion).to eq discussion
      expect(poll.author).to eq user
      expect(poll.admins).to include user

      json = JSON.parse(response.body)
      expect(json['polls'].length).to eq 1
      expect(json['polls'][0]['key']).to eq poll.key
    end

    it 'can create a standalone poll' do
      poll_params[:discussion_id] = nil
      expect { post :create, params: { poll: poll_params } }.to change { Poll.count }.by(1)

      poll = Poll.last
      expect(poll.discussion).to eq nil
      expect(poll.group.presence).to eq nil
      expect(poll.author).to eq user
      expect(poll.admins).to include user
    end

    it 'does not allow non-members to create polls' do
      sign_in another_user
      expect { post :create, params: { poll: poll_params } }.to_not change { Poll.count }
      expect(response.status).to eq 403
    end

    it 'can store an event duration for meeting polls' do
      poll_params[:poll_type] = 'meeting'
      poll_params[:poll_option_names] = [1.day.from_now.iso8601]
      poll_params[:custom_fields] = { meeting_duration: 90, can_respond_maybe: false }
      expect { post :create, params: { poll: poll_params } }.to change { Poll.count }.by(1)
      expect(Poll.last.meeting_duration.to_i).to eq 90
    end

    describe 'group.members_can_raise_motions false' do
      before do
        discussion.group.update(members_can_raise_motions: false)
      end

      it 'admin of formal group can raise motions' do
        discussion.group.add_admin! user
        post :create, params: { poll: poll_params }
        expect(response.status).to eq 200
      end

      it 'member of formal group cannot raise motions' do
        discussion.group.add_member! user
        post :create, params: { poll: poll_params }
        expect(response.status).to eq 403
      end

      it 'guest cannot raise motions' do
        discussion.add_guest! user, discussion.author
        post :create, params: { poll: poll_params }
        expect(response.status).to eq 403
      end
    end

    describe 'group.members_can_raise motions true' do
      before do
        discussion.group.update(members_can_raise_motions: true)
      end

      it 'member of formal group can raise motions' do
        discussion.group.add_member! user
        post :create, params: { poll: poll_params }
        expect(response.status).to eq 200
      end

      it 'guest can raise motions' do
        discussion.add_guest! user, discussion.author
        post :create, params: { poll: poll_params }
        expect(response.status).to eq 200
      end
    end
  end

  describe 'update' do
    before do
      poll.group.add_admin! user
      sign_in user
    end

    it 'updates a poll' do
      post :update, params: { id: poll.key, poll: poll_params }
      expect(response.status).to eq 200
      expect(poll.reload.title).to eq poll_params[:title]
      expect(poll.details).to eq poll_params[:details]
      expect(poll.closing_at).to be_within(1.second).of(poll_params[:closing_at])

      json = JSON.parse(response.body)
      expect(json['polls'].length).to eq 1
      expect(json['polls'][0]['key']).to eq poll.key
    end

    it 'cannot change discussion_id' do
      post :update, params: { id: poll.key, poll: { discussion_id: another_discussion.id } }
      expect(poll.reload.discussion).to eq discussion
    end

    it 'cannot change group_id' do
      post :update, params: { id: poll.key, poll: { group_id: create(:group).id } }
      expect(poll.reload.group_id).to eq group.id
    end

    it 'does not allow members other than the author to update polls' do
      sign_in another_user
      post :update, params: { id: poll.key, poll: poll_params }
      expect(response.status).to eq 403
    end
  end

  describe 'add_options' do
    before { poll.update(voter_can_add_options: true) }

    it 'adds options to a poll' do
      sign_in user
      post :add_options, params: { id: poll.key, poll_option_names: 'new_option' }
      expect(response.status).to eq 200
      expect(poll.reload.poll_option_names).to include 'new_option'

      json = JSON.parse(response.body)
      poll_option_names = json['poll_options'].map { |o| o['name'] }
      expect(poll_option_names).to include 'new_option'
    end

    it 'does not allow unauthorized users to add options' do
      sign_in another_user
      post :add_options, params: { id: poll.key, poll_option_names: 'new_option' }
      expect(response.status).to eq 403
    end

    it 'does nothing if no options passed' do
      sign_in user
      expect { post :add_options, params: { id: poll.key, poll_option_names: [] } }.to_not change { poll.poll_options.count }
      expect(response.status).to eq 200
    end

    it 'cannot add actions to a closed poll' do
      poll.update(closed_at: 1.day.ago)
      sign_in user
      expect { post :add_option, params: { id: poll.key, poll_option_names: 'new_option' } }.to raise_error { CanCan::AccessDenied }
    end
  end

  describe 'close' do
    it 'closes a poll' do
      sign_in user
      post :close, params: { id: poll.key }
      expect(response.status).to eq 200
      expect(poll.reload.active?).to eq false
    end

    it 'does not close an already closed poll' do
      sign_in user
      poll.update(closed_at: 1.day.ago)
      post :close, params: { id: poll.key }
      expect(response.status).to eq 403
    end

    it 'does not allow visitors to close polls' do
      post :close, params: { id: poll.key }
      expect(response.status).to eq 403
      expect(poll.reload.active?).to eq true
    end

    it 'does not allow members other than the author to close polls' do
      sign_in another_user
      post :close, params: { id: poll.key }
      expect(response.status).to eq 403
      expect(poll.reload.active?).to eq true
    end
  end

  describe 'reopen' do
    before do
      sign_in user
      poll.group.add_admin! user
    end

    let(:poll_params) {{
      closing_at: 1.day.from_now
    }}

    before { poll.update(closed_at: 1.day.ago) }

    it 'can reopen a poll' do
      post :reopen, params: { id: poll.key, poll: poll_params }
      expect(response.status).to eq 200

      expect(poll.reload.active?).to eq true
      expect(poll.closing_at).to be_within(1.second).of(poll_params[:closing_at])
    end

    it 'cannot reopen an active poll' do
      poll.update(closed_at: nil)
      post :reopen, params: { id: poll.key, poll: poll_params }
      expect(response.status).to eq 403
    end

    it 'does not allow non-admins to reopen a poll' do
      sign_in another_user
      post :reopen, params: { id: poll.key, poll: poll_params }
      expect(response.status).to eq 403
    end
  end

  describe 'destroy' do
    before do
      sign_in user
      poll.group.add_admin! user
    end

    it 'destroys a poll' do
      expect { delete :destroy, params: { id: poll.key } }.to change { Poll.count }.by(-1)
      expect(response.status).to eq 200
    end

    it 'does not allow an unauthed user to destroy a poll' do
      sign_in create(:user)
      expect { delete :destroy, params: { id: poll.key } }.to_not change { Poll.count }
      expect(response.status).to eq 403
    end
  end

  describe 'add_to_thread' do
    let(:comment) { build :comment, discussion: discussion, author: user }
    let(:poll) { build :poll, title: "Standalone Complex", group: group, author: user }
    let(:discussion) { build :discussion, group: group }

    before do
      sign_in user
      group.add_admin! user
      group.add_admin! discussion.author
      DiscussionService.create(discussion: discussion, actor: discussion.author)
      PollService.create(poll: poll, actor: poll.author)
      CommentService.create(comment: comment, actor: user)
    end

    it "adds poll to thread" do
      expect(poll.created_event.discussion_id).to be nil
      expect(poll.created_event.parent_id).to be nil
      expect(poll.created_event.sequence_id).to be nil
      expect(poll.created_event.position).to be 0

      patch :add_to_thread, params: { id: poll.key, discussion_id: discussion.id }
      expect(response.status).to eq 200

      poll.reload
      discussion.reload

      json = JSON.parse(response.body)
      expect(json.keys).to include 'polls'
      expect(json.keys).to include 'events'

      expect(poll.created_event.discussion_id).to eq discussion.id
      expect(poll.created_event.parent_id).to eq discussion.created_event.id
      expect(poll.created_event.sequence_id).to eq 2
      expect(poll.created_event.position).to eq 2
      expect(discussion.created_event.children.count).to eq 2
      expect(discussion.items_count).to eq 2
    end
  end
end
