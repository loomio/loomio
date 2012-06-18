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
        post :create, :motion => { :discussion_id => discussion.id },
          :group_id => group.id
      end

      it "redirects to discussion url" do
        response.should redirect_to(discussion_url(discussion))
      end

      it "gives flash success message" do
        flash[:success].should =~ /Proposal successfully created./
      end
    end

    context "editing a motion" do
      it "redirects with error if they aren't the author" do
        motion.should_receive(:can_be_edited_by?).with(user).and_return(false)

        get :edit, id: motion.id

        flash[:error].should =~ /Only the author/
        response.should be_redirect
      end

      it "succeeds if they are the author" do
        motion.should_receive(:can_be_edited_by?).with(user).at_least(:once).and_return(true)

        get :edit, id: motion.id

        response.should be_success
      end
    end

    context "deleting a motion" do
      it "succeeds and redirects for author" do
        motion.should_receive(:destroy)
        motion.stub(:has_admin_user?).with(user).and_return(false)
        motion.stub(:author).and_return(user)

        delete :destroy, id: motion.id

        response.should redirect_to(group)
        flash[:success].should =~ /Proposal deleted/
      end

      it "succeeds and redirects for group admin" do
        motion.should_receive(:destroy)
        motion.stub(:has_admin_user?).with(user).and_return(true)
        motion.stub(:author).and_return(double("user"))

        delete :destroy, id: motion.id

        response.should redirect_to(group)
        flash[:success].should =~ /Proposal deleted/
      end

      it "displays error if not author or group admin" do
        motion.should_not_receive(:destroy)
        motion.stub(:has_admin_user?).with(user).and_return(false)
        motion.stub(:author).and_return(double("user"))

        delete :destroy, id: motion.id

        response.should redirect_to(previous_url)
        flash[:error].should =~ /You do not have permission to delete this motion./
      end
    end
  end
end
