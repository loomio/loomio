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
    let(:group_setup){ mock_model(GroupSetup, group_id: group.id) }

    before do
      GroupSetup.stub(:find_by_group_id).and_return(group_setup)
      group_setup.stub(:update_attributes!).and_return(true)
    end

    it 'updates the attributes' do
      group_setup.should_receive(:update_attributes!)
      post :finish, id: group_setup.group_id,
                    group_setup: { group_name: group_setup.group_name }
    end

    it "calls finish! on the group_setup" do
      group_setup.should_receive(:finish!)
      post :finish, id: group_setup.group_id,
                    group_setup: { group_name: group_setup.group_name }
    end

    context "completes successfully" do
      before do
        group_setup.stub(:finish!).and_return(true)
        group_setup.stub(:send_invitations)
      end

      it "calls send_invitations for the group_setup" do
        group_setup.should_receive(:send_invitations)
        post :finish, id: group_setup.group_id,
                      group_setup: { group_name: group_setup.group_name }
      end

      it "redirects to the group page" do
        post :finish, id: group_setup.group_id,
                      group_setup: { group_name: group_setup.group_name }
        response.should redirect_to(group_path(group_setup.group_id))
      end
    end

    context "does not complete successfully" do
      before do
        group_setup.stub(:finish!).and_return(false)
        post :finish, id: group_setup.group_id,
                      group_setup: { group_name: group_setup.group_name }
      end

      it "renders a flash message could not complete" do
        flash[:error].should match("Set up could not complete.")
      end

      it "renders the setup page" do
        response.should render_template('setup')
      end
    end
  end
end