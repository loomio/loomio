require 'spec_helper'

describe DiscussionsController do
  let(:user)  { stub_model(User) }
  let(:discussion) { stub_model(Discussion) }
  let(:group) { stub_model(Group) }

  before :each do
    Discussion.stub(:find).with(discussion.id.to_s).and_return(discussion)
    discussion.stub(:group).and_return(group)
  end

  context "signed in user, posting a comment to a discussion" do
    before :each do
      sign_in user
    end

    it "can add comment" do
      discussion.should_receive(:can_add_comment?).and_return(true)
      discussion.should_receive(:add_comment)
        .with(user, "Hey guys this is my comment!").and_return(double("comment"))

      post :add_comment, comment: "Hello", id: discussion.id

      response.should redirect_to(group_url(discussion.group))
    end
  end

end
