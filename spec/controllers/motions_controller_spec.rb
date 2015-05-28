require 'rails_helper'

describe MotionsController do
  let(:group) { stub_model(Group, full_name: 'Bobs Bakery', key: 'aAa121') }
  let(:user)  { FactoryGirl.create(:user) }
  let(:discussion)  { stub_model(Discussion, group: group, title: 'some discussion', key: 'asdf333') }
  let(:motion) { stub_model(Motion, discussion: discussion, key: 'abc777') }
  let(:previous_url) { root_url }
  let(:permitted_params) { stub_model(PermittedParams, motion: {outcome: 'new outcome'}) }

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

    #context "viewing a motion" do
      #it "redirects to discussion" do
        #pending "this isn't working for some reason"
        #discussion.stub(:current_motion).and_return(motion)
        #get :show, :id => motion.key
        #response.should redirect_to(discussion_url(discussion))
      #end
    #end

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
        expect(flash[:success]).to match(/Proposal deleted/)
      end
    end

    context "updating a motion's outcome" do
      it "updates the motion's outcome" do
        MotionService.should_receive(:update_outcome).with(:motion => motion, :params => permitted_params.motion, :actor => user)
        patch :update_outcome, :id => motion.key, :motion => permitted_params.motion
      end
    end
  end
end
