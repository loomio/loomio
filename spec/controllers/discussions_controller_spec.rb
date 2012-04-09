require 'spec_helper'

describe DiscussionsController do
  let(:user)  { stub_model(User) }
  let(:discussion) { stub_model(Discussion) }
  let(:group) { stub_model(Group) }
  let(:motion) { stub_model(Motion) }
  let(:previous_url) { motion_url(motion) }

  before :each do
    Discussion.stub(:find).with(discussion.id.to_s).and_return(discussion)
    discussion.stub(:group).and_return(group)
    request.env["HTTP_REFERER"] = previous_url
  end

  context "signed in user, posting a comment to a discussion" do
    before :each do
      sign_in user
    end

    it "can add comment if they have permission" do
      discussion.should_receive(:can_add_comment?).and_return(true)
      discussion.stub_chain(:motions, :first).and_return(motion)
      discussion.should_receive(:add_comment)
        .with(user, "Hello!").and_return(double("comment"))

      post :add_comment, comment: "Hello!", id: discussion.id

      response.should redirect_to(motion_url(motion))
    end

    it "cannot add comment if they don't have permission" do
      discussion.should_receive(:can_add_comment?).and_return(false)
      discussion.stub_chain(:motions, :first).and_return(motion)
      discussion.should_not_receive(:add_comment)

      post :add_comment, comment: "Hello!", id: discussion.id

      response.should redirect_to(previous_url)
    end
  end

end
