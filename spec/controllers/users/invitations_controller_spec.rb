require 'spec_helper'

describe Users::InvitationsController do

  let(:user)  { stub_model(User) }
  let(:invited_user)  { stub_model(User) }
  let(:group)  { stub_model(Group) }
  let(:email) { "test@example.com" }

  context "logged-in" do
    before :each do
      sign_in user
      Group.stub(:find).with(group.id.to_s).and_return(group)
      Group.stub(:find).with(group.id, nil).and_return(group)

      # The following line must be called for devise controller tests
      # See: http://stackoverflow.com/a/4321055/307438
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context "user without permission tries to invite member" do
      before :each do
        controller.stub(:can?).with(:add_members, group).and_return(false)
      end

      it "should display error and redirect" do
        post :create, user: {email: "test@example.com", group_id: group.id}

        flash[:error].should match(/You do not have permission/)
        response.should be_redirect
      end
    end

    context "admin user" do
      before :each do
        controller.stub(:can?).with(:add_members, group).and_return(true)
      end

      context "invites member with blank email address" do
        it "should display error"
      end

      context "invites member (with no existing loomio account)" do
        it "should succeed and redirect" do
          User.should_receive(:find_by_email).and_return(nil)
          User.should_receive(:invite_and_notify!).and_return(invited_user)
          invited_user.should_receive(:errors).twice.and_return([])
          Event.should_receive(:user_added_to_group!)

          post :create, user: {email: "test@example.com", group_id: group.id}

          flash[:notice].should match(/An invite has been sent/)
          response.should redirect_to(group_url(group))
        end
      end

      context "invites member (with an existing loomio account)" do
        before :each do
          User.stub(:find_by_email).with(email).and_return(invited_user)
        end

        it "should succeed and redirect if member is not in group" do
          invited_user.should_receive(:groups).and_return([])
          group.should_receive(:add_member!).with(invited_user, user)
          Event.should_receive(:user_added_to_group!)

          post :create, user: {email: email, group_id: group.id}

          flash[:notice].should match(/has been added to the group/)
          response.should redirect_to(group_url(group))
        end

        it "should display alert and redirect if member is already in group" do
          invited_user.should_receive(:groups).and_return([group])
          Event.should_not_receive(:user_added_to_group!)

          post :create, user: {email: email, group_id: group.id}

          flash[:alert].should match(/already in the group/)
          response.should redirect_to(group_url(group))
        end
      end
    end

  end

end
