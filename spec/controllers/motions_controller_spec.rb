require 'spec_helper'

describe MotionsController do
  let(:group) { stub_model(Group) }
  let(:user)  { stub_model(User) }
  let(:motion) { stub_model(Motion, :group => group) }

  before :each do
    Motion.stub(:find).with(motion.id.to_s).and_return(motion)
    Group.stub(:find).with(group.id.to_s).and_return(group)
    group.stub(:can_be_edited_by?).with(user).and_return(true)
  end

  context "signed in user, admin of a group" do
    before :each do
      sign_in user
    end

    it "can close a motion" do
      motion.should_receive(:set_close_date)
      post :close_voting, id: motion.id
    end

    it "can open a motion" do
      motion.should_receive(:set_close_date)
      post :open_voting, id: motion.id
    end
  end

  context "signed in user, in a group" do
    before :each do
      sign_in user
    end

    it "cannot close a motion" do
      pending "This test is not actually passing, the code for this doesn't work"

      motion.should_not_receive(:close_voting!)
      post :close_voting, id: motion.id
    end

    describe "creating a motion" do
      it "can create a motion" do
        motion_attrs = {'key' => 'value'}

        Motion.should_receive(:create).with(motion_attrs).and_return(motion)
        motion.should_receive(:author=).with(user)
        motion.should_receive(:group=).with(group)
        motion.should_receive(:save!)

        post :create, :group_id => group.id, :motion => motion_attrs

        response.should be_redirect
      end
    end

    context "showing a motion" do
      it "succeeds" do
        get :show, group_id: group.id, id: motion.id
        response.should be_success
      end
    end

    context "editing a motion" do
      it "redirects with error if they aren't the author or facilitator" do
        motion.should_receive(:can_be_edited_by?).with(user).and_return(false)

        get :edit, id: motion.id

        flash[:error].should =~ /Only the facilitator/
        response.should be_redirect
      end

      it "succeeds if they are the author" do
        motion.should_receive(:can_be_edited_by?).with(user).and_return(true)

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
        flash[:notice].should =~ /Motion deleted/
      end

      it "succeeds and redirects for group admin" do
        motion.should_receive(:destroy)
        motion.stub(:has_admin_user?).with(user).and_return(true)
        motion.stub(:author).and_return(double("user"))

        delete :destroy, id: motion.id

        response.should redirect_to(group)
        flash[:notice].should =~ /Motion deleted/
      end

      it "displays error if not author or group admin" do
        motion.should_not_receive(:destroy)
        motion.stub(:has_admin_user?).with(user).and_return(false)
        motion.stub(:author).and_return(double("user"))

        delete :destroy, id: motion.id

        response.should redirect_to(motion)
        flash[:error].should =~ /You do not have significant priviledges to do that./
      end
    end
  end
end
