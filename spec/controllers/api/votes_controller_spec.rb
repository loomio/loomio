require 'rails_helper'

describe API::VotesController do

  let(:user)                  { create :user }
  let(:group)                 { create :group }
  let(:discussion)            { create :discussion, group: group }
  let(:motion)                { create :motion, discussion: discussion }
  let(:another_motion)        { create :motion, discussion: discussion }
  let(:my_older_vote)         { create :vote, motion: motion,         user: user, age: 1 }
  let(:my_vote)               { create :vote, motion: motion,         user: user }
  let(:my_other_vote)         { create :vote, motion: another_motion, user: user }
  let(:other_guys_vote)       { create :vote, motion: motion, user: create(:user) }
  let(:vote_params) {{
    stance: { position: 'yes' },
    statement: 'code all the things',
    motion_id: motion.id
  }}

  before do
    motion
    stub_request(:post, "http://localhost:9292/faye").to_return(status: 200)
    group.admins << user
    sign_in user
  end

  describe 'index' do

    before do
      my_older_vote; my_vote; my_other_vote; other_guys_vote
    end

    context 'success' do
      it 'returns votes filtered by motion' do
        get :index, motion_id: motion.id, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[votes])
        motions = json['votes'].map { |v| v['id'] }
        expect(motions).to include my_vote.id
        expect(motions).to include other_guys_vote.id
        expect(motions).to_not include my_other_vote.id
      end
    end

    context 'failure' do
      it 'does not allow access to an unauthorized motion' do
        cant_see_me = create :motion
        get :index, motion_id: cant_see_me.id, format: :json
        expect(response.status).to eq 403
      end
    end
  end

  describe 'my_votes' do
    before do
      my_older_vote; my_vote; my_other_vote; other_guys_vote
    end

    context 'success' do

      let(:other_discussion)         { create :discussion, group: group }
      let(:other_discussion_motion)  { create :motion, discussion: other_discussion }
      let(:my_other_discussion_vote) { create :vote, motion: other_discussion_motion, user: user }

      it 'returns votes filtered by group' do
        my_other_discussion_vote
        get :my_votes, group_id: group.id, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[votes])
        motion_ids = json['votes'].map { |v| v['id'] }
        expect(motion_ids).to include my_vote.id
        expect(motion_ids).to include my_other_vote.id
        expect(motion_ids).to include my_other_discussion_vote.id
        expect(motion_ids).to_not include other_guys_vote.id
      end

      it 'returns votes filtered by discussion and current user' do
        my_other_discussion_vote
        get :my_votes, discussion_id: discussion.id, format: :json
        json = JSON.parse(response.body)
        motion_ids = json['votes'].map { |v| v['id'] }
        expect(motion_ids).to include my_vote.id
        expect(motion_ids).to include my_vote.id
        expect(motion_ids).to include my_other_vote.id
        expect(motion_ids).to_not include other_guys_vote.id
        expect(motion_ids).to_not include my_other_discussion_vote.id
      end

      it 'returns only the most recent vote' do
        get :my_votes, proposal_ids: discussion.motion_ids.join(','), format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[votes])
        motions = json['votes'].map { |v| v['id'] }
        expect(motions).to include my_vote.id
        expect(motions).to_not include my_older_vote.id
      end
    end
  end

  # describe 'update' do
  #   it 'calls VotesController#create' do
  #     expect(VoteService).to receive(:create)
  #     post :update, vote: vote_params
  #   end
  # end

  describe 'create' do

    context 'logged out' do
      before { @controller.stub(:current_user).and_return(LoggedOutUser.new) }
      it 'responds with unauthorized' do
        post :create, vote: vote_params
        expect(response.status).to eq 403
      end
    end

    context 'success' do
      it "creates a vote" do
        post :create, vote: vote_params
        expect(response).to be_success
        expect(Vote.last).to be_present
      end

      it 'responds with json' do
        post :create, vote: vote_params
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[users votes])
        expect(json['votes'][0].keys).to include *(%w[
          id
          stance
          statement
          proposal_id
          author_id
          created_at
        ])
      end

      it 'responds with a discussion with a reader' do
        post :create, vote: vote_params
        json = JSON.parse(response.body)
        expect(json['discussions'][0]['discussion_reader_id']).to be_present
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        vote_params[:dontmindme] = 'wild wooly byte virus'
        post :create, vote: vote_params
        expect(JSON.parse(response.body)['exception']).to eq 'ActionController::UnpermittedParameters'
      end

      let(:another_user)          { create :user }
      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        post :create, vote: vote_params
        expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
      end

      it "responds with validation errors when they exist" do
        vote_params[:stance][:position] = ''
        post :create, vote: vote_params
        json = JSON.parse(response.body)
        expect(response.status).to eq 422
        expect(json['errors']['position']).to be_present
      end

    end
  end
end
