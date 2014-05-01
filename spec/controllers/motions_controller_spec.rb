require 'spec_helper'

describe MotionsController do
  let(:group) { stub_model(Group, full_name: 'Bobs Bakery', key: 'aAa121') }
  let(:user)  { stub_model(User) }
  let(:discussion)  { stub_model(Discussion, group: group, title: 'some discussion', key: 'asdf333') }
  let(:motion) { stub_model(Motion, discussion: discussion, key: 'abc777') }
  let(:previous_url) { root_url }

  before :each do
    Motion.stub(:find_by_key!).with(motion.key).and_return motion
    Group.stub(:find).and_return(group)
    Discussion.stub(:find).and_return(discussion)
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
        @motion_args = { :motion => { :discussion_id => discussion.id,
                                      :close_at_date => Date.today.to_s,
                                      :close_at_time => "5"},
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

      context "where motion already exists" do
        before { discussion.stub(current_motion: true) }
        it "redirects to discussion page" do
          post :create, @motion_args
          response.should redirect_to(discussion_url(discussion))
        end
        it "sets the flash messeage" do
          post :create, @motion_args
          flash[:error].should == I18n.t(:"error.proposal_already_exists")
        end
      end
    end

    context "viewing a motion" do
      it "redirects to discussion" do
        pending "this isn't working for some reason"
        discussion.stub(:current_motion).and_return(motion)
        get :show, :id => motion.key
        response.should redirect_to(discussion_url(discussion))
      end
    end

    context "closing a motion manually" do
      before do
        controller.stub(:authorize!).with(:close, motion).and_return(true)
        MotionService.stub(:close_by_user)
      end

      it "closes the motion" do
        MotionService.should_receive(:close_by_user).with(motion, user)
        put :close, :id => motion.key
      end

      it "redirects back to discussion showing motion as closed" do
        put :close, :id => motion.key
        response.should redirect_to(discussion_url(discussion) + '?proposal=' + motion.key)
      end
    end

    context "changes the close date" do
      before do
        controller.stub(:authorize!).with(:edit_close_date, motion).and_return(true)
      end
      it "checks user has permission" do
        Motion.stub(:find_by_key!).with(motion.key).and_return FactoryGirl.create(:motion, :discussion => discussion)
        controller.should_receive(:authorize!)
        put :edit_close_date, :id => motion.key, :motion => { close_at_date: Time.now,
                          close_at_time: "05:00", close_at_time_zone: "Wellington" }
      end
      context "a valid date is entered" do
        it "calls set_motion_close_date, creates relavent activity and flashes a success" do
          motion.should_receive(:update_attributes).and_return true
          put :edit_close_date, :id => motion.key, :motion => { close_at_date: Time.now,
                          close_at_time: "05:00", close_at_time_zone: "Wellington" }
          flash[:success].should =~ /Close date successfully changed./
          response.should redirect_to(discussion)
        end
      end
      context "an invalid date is entered" do
        it "displays an error message and returns to the discussion page" do
          motion.should_receive(:update_attributes).and_return false
          put :edit_close_date, :id => motion.key, :motion => { :close_date => Time.now,
                  close_at_time: "05:00", close_at_time_zone: "Wellington" }
          flash[:error].should =~ /Invalid close date, please check this date has not passed./
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
        delete :destroy, id: motion.key
      end
      it "redirects to group" do
        delete :destroy, id: motion.key
        response.should redirect_to(group)
      end
      it "gives flash success message" do
        delete :destroy, id: motion.key
        flash[:success].should =~ /Proposal deleted/
      end
    end
  end
end
