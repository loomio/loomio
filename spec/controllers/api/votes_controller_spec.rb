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
  let(:vote_params) {{
    position: 'yes',
    statement: 'code all the things',
    motion_id: motion.id
  }}

  before do
    motion
    stub_request(:post, "http://localhost:9292/faye").to_return(status: 200)
    group.admins << user
    sign_in user
  end

  #describe 'index' do

    #before do
      #my_older_vote; my_vote; my_other_vote; other_guys_vote
    #end

    #context 'success' do
      #it 'returns votes filtered by motion' do
        #get :index, motion_id: motion.id, format: :json
        #json = JSON.parse(response.body)
        #expect(json.keys).to include *(%w[votes])
        #motions = json['votes'].map { |v| v['id'] }
        #expect(motions).to include my_vote.id
        #expect(motions).to include other_guys_vote.id
        #expect(motions).to_not include my_other_vote.id
      #end
    #end

    #context 'failure' do
      #it 'does not allow access to an unauthorized motion' do
        #cant_see_me = create :motion
        #expect { get :index, motion_id: cant_see_me.id, format: :json }.to raise_error
      #end
    #end
  #end

  #describe 'my_votes' do
    #before do
      #my_older_vote; my_vote; my_other_vote; other_guys_vote
    #end

    #context 'success' do
      #it 'returns votes filtered by discussion and current user' do
        #get :my_votes, discussion_id: discussion.id, format: :json
        #json = JSON.parse(response.body)
        #expect(json.keys).to include *(%w[votes])
        #motions = json['votes'].map { |v| v['id'] }
        #expect(motions).to include my_vote.id
        #expect(motions).to include my_other_vote.id
        #expect(motions).to_not include other_guys_vote.id
      #end

      #it 'returns only the most recent vote' do
        #get :my_votes, discussion_id: discussion.id, format: :json
        #json = JSON.parse(response.body)
        #expect(json.keys).to include *(%w[votes])
        #motions = json['votes'].map { |v| v['id'] }
        #expect(motions).to include my_vote.id
        #expect(motions).to_not include my_older_vote.id        
      #end
    #end
  #end

  describe 'create' do
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
          position
          statement
          proposal_id
          author_id
          created_at
        ])
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        vote_params[:dontmindme] = 'wild wooly byte virus'
        post :create, vote: vote_params
        expect(JSON.parse(response.body)['exception']).to eq 'ActionController::UnpermittedParameters'
      end

      let(:another_user)          { create :user }
      it "responds with an error when the user is unauthorized", focus: true do
        sign_in another_user
        post :create, vote: vote_params
        expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
      end

      it "responds with validation errors when they exist" do
        vote_params[:position] = ''
        post :create, vote: vote_params
        json = JSON.parse(response.body)
        expect(response.status).to eq 400
        expect(json['errors']['position']).to include 'can\'t be blank'
      end

    end
  end
end
