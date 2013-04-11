require 'spec_helper'

describe GroupSetupController do
  let(:user){create :user}
  let(:group) { create :group }

  before do
    group.add_admin!(user)
    sign_in user
  end

  describe "#setup" do
    context 'first time setup of group' do
      it 'builds a new group_setup' do
        get :setup, id: group.id
        assigns(:group_setup).should be_present
      end
    end

    context 'subsequent attempt to setup a group' do
      it 'loads existing group_setup for the group' do
        get :setup, id: group.id
        assigns(:group_setup).should be_present
      end
    end
  end

  describe "#finish" do
    let(:group_setup){stub(:group_setup, group_id: 1).as_null_object }

    before do
      GroupSetup.stub(:find_by_group_id).and_return(group_setup)
    end

    context "expectations" do
      after { post :finish, id: group_setup.group_id }

      it "calls build_group for the group_setup" do
        group_setup.should_receive(:compose_group)
      end

      it "calls build_discussion for the group_setup" do
        group_setup.should_receive(:compose_discussion)
      end

      it "calls build_motion for the group_setup" do
        group_setup.should_receive(:compose_motion)
      end

      it "calls save to save all the built objects" do
        group_setup.should_receive(:save!)
      end

      it "calls send_invitations for the group_setup" do
        group_setup.should_receive(:send_invitations)
      end
    end

    it "redirects to the group page" do
      post :finish, id: group_setup.group_id
      response.should redirect_to(group_path(group_setup.group_id))
    end
  end
end