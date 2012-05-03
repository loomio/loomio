require 'spec_helper'

describe DiscussionsController do
  let(:app_controller) { controller }
  let(:user) { stub_model(User) }
  let(:motion) { mock_model(Motion) }
  let(:group) { mock_model(Group) }
  let(:discussion) { stub_model(Discussion, author: user, default_motion: motion, group: group) }

  context "authenticated user" do
    before do
      sign_in user
      app_controller.stub(:authorize!).and_return(true)
      app_controller.stub(:resource).and_return(discussion)
      Discussion.stub(:find).with(discussion.id.to_s).and_return(discussion)
      Discussion.stub(:create).and_return(discussion)
      Group.stub(:find).with(group.id.to_s).and_return(group)
      group.stub(:can_be_viewed_by?).with(user).and_return(true)
      group.stub_chain(:users, :include?).with(user).and_return(true)
    end

    context "creates a discussion" do
      it "adds a comment" do
        discussion.should_receive(:add_comment).with(user, "Bright light")
        discussion.should_receive(:save).and_return(true)
        get :create, discussion: { group_id: group.id, title: "Shinney", comment: "Bright light" }
        response.should redirect_to(discussion_path(discussion))
      end
    end

    context "adds comment" do
      before do
        discussion.stub(:add_comment)
      end

      it "checks permissions" do
        app_controller.should_receive(:authorize!).and_return(true)
        post :add_comment, comment: "Hello!", id: discussion.id
      end

      it "adds comment" do
        discussion.should_receive(:add_comment).with(user, "Hello!")
        post :add_comment, comment: "Hello!", id: discussion.id
      end

      it "redirects to the discussion's default motion" do
        post :add_comment, comment: "Hello!", id: discussion.id
        response.should redirect_to(motion_path(motion))
      end
    end
  end
end
