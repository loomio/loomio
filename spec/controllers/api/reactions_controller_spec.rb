require 'rails_helper'

describe API::ReactionsController do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:comment) { create :comment }
  let(:reaction) { create :reaction, user: user, reactable: comment }
  let(:reaction_params) { {
    reaction: '+1',
    reactable_id: comment.id,
    reactable_type: 'Comment'
  } }

  describe 'create' do

    before { comment.group.add_member! user }

    context 'success' do
      it "likes the comment" do
        sign_in user
        post :create, params: { reaction: reaction_params }
        expect(comment.reload.reactors).to include user
      end
    end

    context 'failure' do
      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        post :create, params: { reaction: reaction_params }
        expect(response.status).to eq 403
        expect(JSON.parse(response.body)['exception']).to include 'CanCan::AccessDenied'
      end
    end
  end

  describe 'index' do
    it "fetches reactions for multiple records at once" do
      comment_reaction = create :reaction, user: user, reactable: comment
      discussion_reaction = create :reaction, user: user, reactable: comment.discussion
      comment.discussion.group.add_member! user
      sign_in user

      get :index, params: { comment_ids: [comment.id], discussion_ids: [comment.discussion.id]}

      expect(JSON.parse(response.body)['reactions'].length).to eq 2
    end

    it "denies access correctly" do
      comment_reaction = create :reaction, user: user, reactable: comment
      discussion_reaction = create :reaction, user: user, reactable: comment.discussion
      sign_in user

      get :index, params: { comment_ids: [comment.id], discussion_ids: [comment.discussion.id]}
      expect(response.status).to eq 403
    end
  end

end
