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
        expect(JSON.parse(response.body)['exception']).to include 'CanCan::AccessDenied'
      end
    end
  end

  # TODO: support for deleting likes
  # describe 'unlike' do
  #   context 'success' do
  #     it "unlikes the comment" do
  #       comment.reactions << reaction
  #       sign_in user
  #       delete :destroy, id: reaction.id
  #       expect(response.status).to eq 200
  #       expect(comment.reload.reactors).to_not include user
  #     end
  #   end
  # end
end
