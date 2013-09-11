require 'spec_helper'
describe Groups::InvitationsController do
  before do
    @group = FactoryGirl.create(:group)
    @user = FactoryGirl.create(:user)
    @group.add_admin!(@user)
    sign_in @user
  end

  context 'create' do
    # let(:invalid_invite_people){stub(:invite_people, valid?: false)}

    # it 'renders new if invite_people is invalid' do
    #   InvitePeople.should_receive(:new).and_return(invalid_invite_people)
    #   post :create, group_id: @group.id, invite_people: {recipients: "bob"}
    #   response.should render_template(:new)
    # end
  end

  describe 'destroy' do
    let(:invitation){stub(:invitation,
                          recipient_email: 'jim@jam.com',
                          cancel!: true)}

    before do
      Group.stub(:find).and_return(@group)
      Group.stub(:find_by_id).and_return(@group)
      GroupDecorator.stub(:new).and_return(@group)
      @group.stub_chain(:pending_invitations, :find).and_return(invitation)
    end

    it 'cancels the invitation' do
      p @group
      p invitation
      invitation.should_receive(:cancel!).with({:canceller => @user})
      delete :destroy, group_id: @group.id, id: 4
    end

    it 'redirects to group_invitations_path with flash notice' do
      delete :destroy, group_id: @group.id
      response.should redirect_to group_invitations_path(@group)
    end
  end
end
