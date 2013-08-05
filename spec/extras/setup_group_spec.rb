require 'spec_helper'

describe SetupGroup do
  before do
    @approver = FactoryGirl.create(:user)
    @group_request = FactoryGirl.create(:group_request)
    @setup_group = SetupGroup.new(@group_request)
    @paying_subscription = true
  end

  describe '#setup(paying_subscription)' do

    it 'assigns the group_request name to the group' do
      @group = @setup_group.setup(@paying_subscription)
      @group.name.should == @group_request.name
    end

    it 'assigns the payment model to the group' do
      @group = @setup_group.setup(@paying_subscription)
      @group.paying_subscription.should == @paying_subscription
    end

    it 'assigns the group_request to the group' do
      @group = @setup_group.setup(@paying_subscription)
      @group.group_request.should == @group_request
    end

    it 'creates the group' do
      @group = @setup_group.setup(@paying_subscription)
      @group.should be_persisted
    end

    it 'sends an invitation to start the group' do
      @setup_group.should_receive(:send_invitation_to_start_group)
      @group = @setup_group.setup('pwyc')
    end
  end
end
