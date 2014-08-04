require 'rails_helper'

describe GroupsHelper do
  let(:group) { FactoryGirl.create(:group) }
  let(:subgroup) { FactoryGirl.create(:group, parent: group) }
  let(:user) { FactoryGirl.create(:user) }

  context "show_subscription_prompt?" do
    before do
      helper.stub(:current_user).and_return true
      helper.stub(:user_signed_in?).and_return true
      helper.stub_chain(:current_user, :is_group_admin?).and_return true
      group.add_admin! user
    end

    it "returns false for new groups" do
      helper.show_subscription_prompt?(group).should be false
    end

    it "returns false for paying groups" do
      group.update_attribute(:payment_plan, 'manual_subscription')
      helper.show_subscription_prompt?(group).should be false
    end

    it "returns false for sub groups" do
      subgroup.update_attribute(:created_at, 1.month.ago)
      helper.show_subscription_prompt?(subgroup).should be false
    end

    it "returns true for older unpaying groups" do
      group.update_attribute(:created_at, 1.month.ago)
      helper.show_subscription_prompt?(group).should be true
    end
  end
end
