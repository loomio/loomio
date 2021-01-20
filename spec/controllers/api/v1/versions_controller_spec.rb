require 'rails_helper'
describe API::V1::VersionsController do

  let(:user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:comment) { create :comment, discussion: discussion, author: user }

  before do
    group.add_member! user
    DiscussionService.create(discussion: discussion, actor: discussion.author)
  end

  describe "show" do
    before do
      sign_in user
    end

    it "comment" do
      CommentService.create(comment: comment, actor: user)
      get :show, params: {comment_id: comment.id}
      expect(response.status).to eq 200
    end

    it "discarded comment" do
      CommentService.create(comment: comment, actor: user)
      CommentService.discard(comment: comment, actor: user)
      get :show, params: {comment_id: comment.id}
      expect(response.status).to eq 403
    end
  end
end
