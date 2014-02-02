require 'spec_helper'
describe GroupBaseController do
  context 'require_current_user_can_invite_people' do
    let(:group){ double(:group, key: 'abc312') }
    let(:user) { double(:user).as_null_object }

    before do
      controller.stub(:current_user).and_return(user)
      Group.stub(:find_by_key!).and_return(group)
    end

    after do
      controller.send :require_current_user_can_invite_people
    end

    context 'user can invite members' do
      it 'does not redirect' do
        controller.should_receive(:can?).with(:invite_people, group).and_return(true)
        controller.should_not_receive :redirect_to
      end
    end
    context 'user cannot invite members' do
      it "redirects" do
        controller.should_receive(:can?).with(:invite_people, group).and_return(false)
        controller.should_receive :redirect_to
      end
    end
  end
end
