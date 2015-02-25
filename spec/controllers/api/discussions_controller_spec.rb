require 'rails_helper'
describe API::DiscussionsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:comment) { create :comment, discussion: discussion}
  let(:proposal) { create :motion, discussion: discussion, author: user }
  let(:discussion_params) {{
    title: 'Did Charlie Bite You?',
    description: 'From the dawn of internet time...',
    group_id: group.id,
    private: true
  }}

  before do
    group.add_admin! user
    sign_in user
  end

  describe 'show' do
    it 'returns the discussion json' do
      proposal
      get :show, id: discussion.key
      json = JSON.parse(response.body)
      expect(json.keys).to include *(%w[users groups proposals discussions])
      expect(json['discussions'][0].keys).to include *(%w[id key title description last_item_at last_comment_at created_at updated_at items_count comments_count private author_id group_id active_proposal_id])
    end
  end

  describe 'mark_as_read' do
    it "Marks context/discusion as read" do
      patch :mark_as_read, id: discussion.key, sequence_id: 0
      dr = DiscussionReader.for(discussion: discussion,
                                user: user)
      expect(dr.last_read_at).to eq discussion.created_at
      expect(dr.last_read_sequence_id).to eq 0
    end

    it "Marks thread item as read", focus: true do
      event = CommentService.create(comment: comment, actor: discussion.author)
      patch :mark_as_read, id: discussion.key, sequence_id: event.sequence_id

      dr = DiscussionReader.for(discussion: discussion, user: user)
      expect(dr.last_read_at).to eq event.created_at
      expect(dr.last_read_sequence_id).to eq 1
    end
  end

  #describe 'index' do
    #let(:another_discussion)    { create :group }

    #before do
      #discussion; another_discussion
    #end

    #context 'success' do
      #it 'returns discussions filtered by group' do
        #get :index, group_id: group.id, format: :json
        #json = JSON.parse(response.body)
        #expect(json.keys).to include *(%w[discussions])
        #discussions = json['discussions'].map { |v| v['id'] }
        #expect(discussions).to include discussion.id
        #expect(discussions).to_not include another_discussion.id
      #end

      #it 'does not display discussions not visible to the current user' do
        #cant_see_me = create :discussion
        #get :index, format: :json
        #json = JSON.parse(response.body)
        #discussions = json['discussions'].map { |v| v['id'] }
        #expect(discussions).to_not include cant_see_me.id
      #end
    #end
  #end

  describe 'update' do
    context 'success' do
      it "updates a discussion" do
        post :update, id: discussion.id, discussion: discussion_params, format: :json
        expect(response).to be_success
        expect(discussion.reload.title).to eq discussion_params[:title]
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        discussion_params[:dontmindme] = 'wild wooly byte virus'
        put :update, id: discussion.id, discussion: discussion_params
        expect(JSON.parse(response.body)['exception']).to eq 'ActionController::UnpermittedParameters'
      end

      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        put :update, id: discussion.id, discussion: discussion_params
        expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
      end

      it "responds with validation errors when they exist" do
        discussion_params[:title] = ''
        put :update, id: discussion.id, discussion: discussion_params, format: :json
        json = JSON.parse(response.body)
        expect(response.status).to eq 422
        expect(json['errors']['title']).to include 'can\'t be blank'
      end
    end
  end

  describe 'create' do
    context 'success' do
      it "creates a discussion" do
        post :create, discussion: discussion_params, format: :json
        expect(response).to be_success
        expect(Discussion.last).to be_present
      end

      it 'responds with json' do
        post :create, discussion: discussion_params, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[users groups proposals discussions])
        expect(json['discussions'][0].keys).to include *(%w[
          id
          key
          title
          description
          last_item_at
          last_comment_at
          created_at
          updated_at
          items_count
          comments_count
          private
          active_proposal_id
          author_id
          group_id
        ])
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        discussion_params[:dontmindme] = 'wild wooly byte virus'
        post :create, discussion: discussion_params
        expect(JSON.parse(response.body)['exception']).to eq 'ActionController::UnpermittedParameters'
      end

      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        post :create, discussion: discussion_params
        expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
      end

      it "responds with validation errors when they exist" do
        discussion_params[:title] = ''
        post :create, discussion: discussion_params, format: :json
        json = JSON.parse(response.body)
        expect(response.status).to eq 422
        expect(json['errors']['title']).to include 'can\'t be blank'
      end
    end
  end

end
