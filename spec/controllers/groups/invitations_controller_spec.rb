require 'spec_helper'
describe Groups::InvitationsController do
  before do
    @group = FactoryGirl.create(:group)
    @user = FactoryGirl.create(:user)
    @group.add_admin!(@user)
    controller.stub(:authenticate_user!)
    controller.stub(:current_user).and_return(@user)
  end

  context 'create' do
    let(:invalid_invite_people){stub(:invite_people, valid?: false)}

    it 'renders new if invite_people is invalid' do
      InvitePeople.should_receive(:new).and_return(invalid_invite_people)
      post :create, group_id: @group.id
      response.should render_template(:new)
    end
  end
end

