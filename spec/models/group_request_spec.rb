require 'spec_helper'

describe GroupRequest do
  let(:user) { create(:user) }

  before do
    @group_request = build(:group_request)
  end

  describe 'destroy' do
    before do
      @group_request = FactoryGirl.create(:group_request)
    end

    it 'returns normaly (ie: itself)' do
      @group_request.destroy.should == @group_request
    end

    context 'if group present?' do
      before do
        @group_request.group = FactoryGirl.create(:group)
      end

      it 'returns false if group associated' do
        @group_request.destroy.should be_false
      end
    end
  end
end
