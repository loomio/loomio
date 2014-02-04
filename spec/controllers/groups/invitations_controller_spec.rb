require 'spec_helper'
describe Groups::InvitationsController do
  before do
    @group = FactoryGirl.create(:group)
    @user = FactoryGirl.create(:user)
    @group.add_admin!(@user)
    sign_in @user
  end

  context 'new' do
    it 'redirects with flash error if subgroup' do
      @subgroup = Group.create(name: 'subgroup', parent: @group)
      get :new, group_id: @subgroup.key
      response.should be_redirect
      flash[:error].should == 'You are not able to invite people to this group'
    end
  end

  describe 'destroy' do
    let(:invitation){double(:invitation,
                          recipient_email: 'jim@jam.com',
                          cancel!: true)}

    before do
      Group.stub_chain(:published, :find_by_key!).and_return(@group)
      @group.stub_chain(:pending_invitations, :find).and_return(invitation)
    end

    it 'cancels the invitation' do
      invitation.should_receive(:cancel!).with({:canceller => @user})
      delete :destroy, group_id: @group.key
    end

    it 'redirects to group_memberships_path with flash notice' do
      delete :destroy, group_id: @group.key
      response.should redirect_to group_memberships_path(@group)
    end
  end
end
