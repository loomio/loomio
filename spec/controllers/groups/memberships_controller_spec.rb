require 'spec_helper'

describe Groups::MembershipsController do
  context 'signed in user' do
    before :each do
      @user = create(:user)
      sign_in @user
      @new_user = create(:user)
      @group = create(:group)
      request.env["HTTP_REFERER"] = group_url(@group)
    end

    context "requests membership to a group visible to everyone" do
      before do
        @group.update_attributes({viewable_by: :everyone})
      end
      it "should succeed and redirect to group show page" do
        @group.update_attributes({viewable_by: :everyone})
        post :create, :membership => {:group_id => @group.id}
        response.should redirect_to(group_url(@group))
        assigns(:group).requested_users.should include(@user)
      end
    end

    context "cancels their own membership request" do
      before do
        @membership = @group.add_request!(@user)
        post :cancel_request, :id => @membership.id
      end

      it { @group.requested_users.should_not include(@user) }
      it { flash[:notice].should =~ /Membership request canceled/ }
      it { response.should redirect_to(@group) }
    end

    it "sends an email to admins with new membership request" do
      GroupMailer.should_receive(:new_membership_request).and_return(stub(deliver: true))
      @group.add_admin!(create(:user))
      post :create,
           :membership => {:group_id => @group.id}
    end

    context 'group admin' do
      before :each do
        @group.add_admin!(@user)
      end

      it "can edit a user" do
        membership = @group.add_member!(@new_user)
        get :edit, :id => membership.id
      end

      it 'can add an admin' do
        @membership = @group.add_member!(@new_user)
        post :make_admin, :id => @membership.id, group_id: @group.id
        flash[:notice].should =~ /#{@new_user.name} has been made an admin./
        response.should redirect_to(group_memberships_path(@group))
        assigns(:membership).access_level.should == 'admin'
        @group.admins.should include(@new_user)
      end

      context "removes a member" do
        before do
          @group.add_member!(@new_user)
          @membership = @group.memberships.find_by_user_id(@new_user.id)
          delete :destroy, :id => @membership.id
        end
        it { flash[:notice].should =~ /Member removed/ }
        it { response.should redirect_to group_memberships_path(@group) }
        it { @group.users.should_not include(@new_user) }

        context "that was already removed" do
          before { delete :destroy, :id => @membership.id }

          it { response.should redirect_to(@group) }
        end
      end

      it 'cannot remove an admin' do
        @membership = @group.add_admin!(@new_user)
        post :remove_admin, :id => @membership.id, group_id: @group.id
        flash[:notice].should =~ /#{@membership.user_name}'s admin rights have been removed./
        response.should redirect_to(group_memberships_path(@group))
        assigns(:membership).access_level.should == 'member'
        @group.admins.should_not include(@new_user)
      end
    end

    context 'group member' do
      before :each do
        @group.add_member!(@user)
      end

      context "approves a membership request" do
        before do
          @membership = @group.add_request!(@new_user)
        end
        it "adds membership to group" do
          post :approve_request, :id => @membership.id, group_id: @group.id
          @group.users.should include(@new_user)
        end
        it "gives flash success notice" do
          post :approve_request, :id => @membership.id
          flash[:notice].should =~ /Membership approved/
        end
        it "redirects to group" do
          post :approve_request, :id => @membership.id
          response.should redirect_to(@group)
        end
        it "sends an email to notify the user of their membership approval" do
          UserMailer.should_receive(:group_membership_approved).and_return(stub(deliver: true))
          post :approve_request, :id => @membership.id
        end
        it "does not send a notification email if member is already approved" do
          @membership = @group.add_member!(@new_user)
          UserMailer.should_not_receive(:group_membership_approved)
          post :approve_request, :id => @membership.id
        end
      end

      context "ignores a membership request" do
        before do
          @membership = @group.add_request!(@new_user)
          post :ignore_request, :id => @membership.id
        end

        it { flash[:notice].should =~ /Membership request ignored/ }

        it { response.should redirect_to(@group) }

        it { Membership.exists?(@membership).should be_false }

        context "request was already ignored" do
          before { post :ignore_request, :id => @membership.id }

          it { response.should redirect_to(@group) }

          it { flash[:warning].should =~ /Membership request has already been ignored/ }
        end
      end
    end
  end
end
