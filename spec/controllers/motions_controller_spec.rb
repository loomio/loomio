require 'spec_helper'

describe MotionsController do
  let(:group) { stub_model(Group) }
  let(:user)  { stub_model(User) }
  let(:discussion)  { stub_model(Discussion, :group => group) }
  let(:motion) { stub_model(Motion, :discussion => discussion) }
  let(:previous_url) { root_url }

  before :each do
    Motion.stub(:find).with(motion.id.to_s).and_return(motion)
    Group.stub(:find).with(group.id.to_s).and_return(group)
    Discussion.stub(:find).with(discussion.id.to_s).and_return(discussion)
    user.stub(:update_motion_read_log).with(motion)
    request.env["HTTP_REFERER"] = previous_url
  end

  context "signed in user, in a group" do
    before :each do
      sign_in user
    end

    context "creating a motion" do
      before do
        Motion.stub(:new).and_return(motion)
        Event.stub(:new_motion!)
        motion.stub(:save).and_return(true)
        controller.stub(:authorize!).with(:create, motion).and_return(true)
        @motion_args = { :motion => { :discussion_id => discussion.id },
          :group_id => group.id }
      end
      it "redirects to discussion page" do
        post :create, @motion_args
        response.should redirect_to(discussion_url(discussion))
      end
      it "sets the flash success message" do
        post :create, @motion_args
        flash[:success].should =~ /Proposal successfully created./
      end
      it "fires the new_motion event" do
        Event.should_receive(:new_motion!)
        post :create, @motion_args
      end
    end

    context "viewing a motion" do
      it "redirects to discussion" do
        discussion.stub(:current_motion).and_return(motion)
        get :show, :id => motion.id
        response.should redirect_to(discussion_url(discussion))
      end
    end

    context "closing a motion" do
      before do
        controller.stub(:authorize!).with(:close_voting, motion).and_return(true)
        motion.stub(:close_voting!)
        Event.stub(:close_motion!)
      end

      it "closes the motion" do
        motion.should_receive(:close_voting!)
        post :close_voting, :id => motion.id
      end

      it "fires the close_motion event" do
        Event.should_receive(:close_motion!)
        post :close_voting, :id => motion.id
      end
    end

    context "deleting a motion" do
      before do
        motion.stub(:destroy)
        controller.stub(:authorize!).with(:destroy, motion).and_return(true)
      end
      it "destroys motion" do
        motion.should_receive(:destroy)
        delete :destroy, id: motion.id
      end
      it "redirects to group" do
        delete :destroy, id: motion.id
        response.should redirect_to(group)
      end
      it "gives flash success message" do
        delete :destroy, id: motion.id
        flash[:success].should =~ /Proposal deleted/
      end
    end
  end
end
