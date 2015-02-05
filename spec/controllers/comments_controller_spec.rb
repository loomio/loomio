require 'rails_helper'

describe CommentsController do
  let(:app_controller) { controller }
  let(:group) { create :group }
  let(:user) { create :user }
  let(:discussion) { create :discussion, group: group }
  let(:comment) { create :comment, discussion: discussion }

  context "authenticated user" do
    before do
      sign_in user
      group.add_member! user
    end

    context "user likes a comment" do
      it "adds like to comment model" do
        expect(comment.likes_count).to eq 0
        post :like, id: comment.id, like: 'true', format: :js
        expect(comment.reload.likes_count).to eq 1
      end

      it "fires comment_liked! event" do
        Events::CommentLiked.should_receive(:publish!)
        post :like, id: comment.id, like: 'true', format: :js
      end
    end

  end
end
