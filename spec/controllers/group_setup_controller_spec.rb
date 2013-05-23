require 'spec_helper'

describe Groups::GroupSetupController do
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
    context 'group is already setup' do
      it 'redirects to an error page' do
        group.setup_completed_at = Time.now
        group.save!
        get :setup, id: group.id
        response.should render_template('application/display_error', message: I18n.t('error.group_already_setup'))
      end
    end
  end

  describe "#finish" do
    let(:group_setup){ mock_model(GroupSetup, group_id: group.id) }

    before do
      GroupSetup.stub(:find_by_group_id).and_return(group_setup)
      CreateInvitation.stub(:to_people_and_email_them).and_return(3)
      group_setup.stub(:update_attributes).and_return(true)
      group_setup.stub(:admin_email=).with(user.email)
      group = stub(:group)
      group.stub(:setup_completed_at=)
      group.stub(:save!)
      group_setup.stub(:group).and_return(group)
    end

    context 'expectations' do
      after { post :finish, id: group_setup.group_id,
                    group_setup: { group_name: "plink", message_body: "Welcome" }}

      it 'updates the attributes' do
        group_setup.stub(:finish!).and_return(true)
        group_setup.should_receive(:update_attributes)
      end

      it "calls finish! on the group_setup" do
        group_setup.should_receive(:finish!)
      end
    end

    context 'responses' do
      context "completes successfully" do
       before do
          group_setup.stub(:finish!).and_return(true)
          post :finish, id: group_setup.group_id,
                group_setup: { group_name: "plink", message_body: "Welcome" }
        end

        it "redirects to the finished page" do
          response.should redirect_to(group_path)
        end
      end

      context "does not complete successfully" do
        before do
          group_setup.stub(:finish!).and_return(false)
          post :finish, id: group_setup.group_id,
                group_setup: { group_name: "plink", message_body: "Welcome" }
        end
        it "renders the setup page" do
          response.should render_template('setup')
        end
      end
    end
  end
end
