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
    end

    context "viewing a motion" do
      it "redirects to discussion" do
        pending "this isn't working for some reason"
        discussion.stub(:current_motion).and_return(motion)
        get :show, :id => motion.id
        response.should redirect_to(discussion_url(discussion))
      end
    end

    context "closing a motion" do
      before do
        controller.stub(:authorize!).with(:close, motion).and_return(true)
        motion.stub(:close!)
        motion.stub(:close_motion!)
        Event.stub(:motion_closed!)
      end

      it "closes the motion" do
        motion.should_receive(:close_motion!)
        put :close, :id => motion.id
      end

      it "redirects back to discussion showing motion as closed" do
        put :close, :id => motion.id
        response.should redirect_to(discussion_url(discussion) + '?proposal=' + motion.id.to_s)
      end
    end

    context "changes the close date" do
      before do
        Motion.stub(:find).and_return motion
        controller.stub(:authorize!).with(:edit_close_date, motion).and_return(true)
      end
      it "checks user has permission" do
        controller.should_receive(:authorize!)
        put :edit_close_date, :id => motion.id, :motion => { :close_date => Time.now }
      end
      context "a valid date is entered" do
        it "calls set_motion_close_date, creates relavent activity and flashes a success" do
          motion.should_receive(:set_close_date!).and_return true
          put :edit_close_date, :id => motion.id, :motion => { :close_date => Time.now }
          flash[:success].should =~ /Close date successfully changed./
          response.should redirect_to(discussion)
        end
      end
      context "an invalid date is entered" do
        it "displays an error message and returns to the discussion page" do
          motion.should_receive(:set_close_date!).and_return false
          put :edit_close_date, :id => motion.id, :motion => { :close_date => Time.now }
          flash[:error].should =~ /Invalid close date, it needs to be a furture date./
          response.should redirect_to(discussion)
        end
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
