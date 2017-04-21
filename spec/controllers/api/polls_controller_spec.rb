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
      get :show, id: poll.key
      json = JSON.parse(response.body)
      expect(json['polls'].length).to eq 1
      expect(json['polls'][0]['key']).to eq poll.key
    end

    it 'does not show a poll you do not have access to' do
      sign_in another_user
      get :show, id: poll.key
      expect(response.status).to eq 403
    end
  end

  describe 'index' do
    before { poll; another_poll; closed_poll }

    it 'shows polls in a discussion' do
      sign_in user
      get :index, discussion_id: discussion.key
      json = JSON.parse(response.body)
      poll_keys = json['polls'].map { |p| p['key'] }
      expect(poll_keys).to include poll.key
      expect(poll_keys).to_not include another_poll.key
      expect(poll_keys).to_not include non_group_poll.key
    end

    it 'does not allow user to see polls theyre not allowed to see' do
      sign_in user
      get :index, discussion_id: non_group_discussion.key
      expect(response.status).to eq 403
    end
  end

  describe 'search' do
    let(:participated_poll) { create :poll }
    let!(:my_stance) { create :stance, poll: participated_poll, participant: user, poll_options: [participated_poll.poll_options.first] }
    let!(:authored_poll) { create :poll, author: user }
    let!(:group_poll) { create :poll, discussion: discussion }
    let!(:another_poll) { create :poll }

    describe 'search_results_count' do
      it 'returns a count of possible results' do
        sign_in user
        get :search_results_count
        expect(response.body.to_i).to eq 4
      end
    end

    describe 'signed in' do
      before { sign_in user }

      it 'returns visible polls' do
        get :search
        json = JSON.parse(response.body)
        poll_ids = json['polls'].map { |p| p['id'] }

        expect(poll_ids).to include participated_poll.id
        expect(poll_ids).to include authored_poll.id
        expect(poll_ids).to include group_poll.id
        expect(poll_ids).to_not include another_poll.id
      end

      it 'filters by status' do
        authored_poll.update(closed_at: 1.day.ago)
        get :search, status: :closed

        json = JSON.parse(response.body)
        poll_ids = json['polls'].map { |p| p['id'] }

        expect(poll_ids).to include authored_poll.id
        expect(poll_ids).to_not include participated_poll.id
        expect(poll_ids).to_not include group_poll.id
        expect(poll_ids).to_not include another_poll.id
      end

      it 'filters by group' do
        get :search, group_key: group.key
        json = JSON.parse(response.body)
        poll_ids = json['polls'].map { |p| p['id'] }

        expect(poll_ids).to include group_poll.id
        expect(poll_ids).to_not include participated_poll.id
        expect(poll_ids).to_not include authored_poll.id
        expect(poll_ids).to_not include another_poll.id
      end

      it 'filters by participated' do
        get :search, user: :participation_by
        json = JSON.parse(response.body)
        poll_ids = json['polls'].map { |p| p['id'] }

        expect(poll_ids).to include participated_poll.id
        expect(poll_ids).to_not include group_poll.id
        expect(poll_ids).to_not include authored_poll.id
        expect(poll_ids).to_not include another_poll.id
      end

      it 'filters by authored' do
        get :search, user: :authored_by
        json = JSON.parse(response.body)
        poll_ids = json['polls'].map { |p| p['id'] }

        expect(poll_ids).to include authored_poll.id
        expect(poll_ids).to_not include participated_poll.id
        expect(poll_ids).to_not include group_poll.id
        expect(poll_ids).to_not include another_poll.id
      end

      it 'filters by search fragment' do
        authored_poll.update(title: "Made in Korea!")
        get :search, query: "Korea"
        json = JSON.parse(response.body)
        poll_ids = json['polls'].map { |p| p['id'] }

        expect(poll_ids).to include authored_poll.id
        expect(poll_ids).to_not include group_poll.id
        expect(poll_ids).to_not include participated_poll.id
        expect(poll_ids).to_not include another_poll.id
      end
    end
  end

  describe 'create' do
    it 'creates a poll' do
      sign_in user
      expect { post :create, poll: poll_params }.to change { Poll.count }.by(1)
      expect(response.status).to eq 200

      poll = Poll.last
      expect(poll.title).to eq poll_params[:title]
      expect(poll.discussion).to eq discussion
      expect(poll.author).to eq user
      expect(poll.communities.map(&:class)).to include Communities::LoomioGroup
      expect(poll.communities.map(&:class)).to include Communities::Email

      json = JSON.parse(response.body)
      expect(json['polls'].length).to eq 1
      expect(json['polls'][0]['key']).to eq poll.key
    end

    it 'can create a standalone poll' do
      sign_in user
      poll_params[:discussion_id] = nil
      expect { post :create, poll: poll_params }.to change { Poll.count }.by(1)

      poll = Poll.last
      expect(poll.discussion).to eq nil
      expect(poll.group).to eq nil
      expect(poll.communities.map(&:class)).to include Communities::Public
      expect(poll.communities.map(&:class)).to include Communities::Email
    end

    it 'does not allow visitors to create polls' do
      expect { post :create, poll: poll_params }.to_not change { Poll.count }
      expect(response.status).to eq 403
    end

    it 'does not allow non-members to create polls' do
      sign_in another_user
      expect { post :create, poll: poll_params }.to_not change { Poll.count }
      expect(response.status).to eq 403
    end
  end

  describe 'update' do
    it 'updates a poll' do
      sign_in user
      post :update, id: poll.key, poll: poll_params
      expect(poll.reload.title).to eq poll_params[:title]
      expect(poll.details).to eq poll_params[:details]
      expect(poll.closing_at).to be_within(1.second).of(poll_params[:closing_at])

      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json['polls'].length).to eq 1
      expect(json['polls'][0]['key']).to eq poll.key
    end

    it 'cannot move a poll between discussions' do
      post :update, id: poll.key, poll: { discussion_id: another_discussion.id }
      expect(poll.reload.discussion).to eq discussion
    end

    it 'does not allow visitors to update polls' do
      post :update, id: poll.key, poll: poll_params
      expect(response.status).to eq 403
    end

    it 'does not allow members other than the author to update polls' do
      sign_in another_user
      post :update, id: poll.key, poll: poll_params
      expect(response.status).to eq 403
    end
  end

  describe 'close' do
    it 'closes a poll' do
      sign_in user
      post :close, id: poll.key
      expect(response.status).to eq 200
      expect(poll.reload.active?).to eq false
    end

    it 'does not close an already closed poll' do
      sign_in user
      poll.update(closed_at: 1.day.ago)
      post :close, id: poll.key
      expect(response.status).to eq 403
    end

    it 'does not allow visitors to close polls' do
      post :close, id: poll.key
      expect(response.status).to eq 403
      expect(poll.reload.active?).to eq true
    end

    it 'does not allow members other than the author to close polls' do
      sign_in another_user
      post :close, id: poll.key
      expect(response.status).to eq 403
      expect(poll.reload.active?).to eq true
    end

    it 'converts a poll in a loomio group to a loomio user community' do
      sign_in user
      post :close, id: poll.key
      expect(poll.communities.map(&:class)).to_not include Communities::LoomioGroup
      expect(poll.communities.map(&:class)).to include Communities::LoomioUsers
    end
  end
end
