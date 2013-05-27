require 'spec_helper'

describe SetupGroup do
  before do
    @approver = FactoryGirl.create(:user)
    @group_request = FactoryGirl.create(:group_request)
    @setup_group = SetupGroup.new(@group_request)
    @group_request.verify!
  end

  describe 'approve_group_request' do
    before do
      @group = @setup_group.approve_group_request(approved_by: @approver)
    end

    it 'creates the group' do
      @group.should be_persisted
    end

    it 'copies attributes from group_request' do
      %w[name country_name cannot_contribute max_size].each do |attr|
        @group.send(attr).should == @group_request.send(attr)
      end
    end

    it 'aprroves the group request' do
      @group_request.should be_approved
    end

    it 'assigns the group_request to the group' do
      @group.group_request.should == @group_request
    end

    it 'records who approved the group request' do
      @group_request.approved_by.should == @approver
    end
  end
end
