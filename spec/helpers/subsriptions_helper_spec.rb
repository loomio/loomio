require 'spec_helper'

describe SubscriptionsHelper do
	describe "#get_payment_details_path(group)" do
		let(:group){ create :group }

		context 'group has a subscription plan' do
			it 'returns the path to the payment details page' do
				group.stub(:has_subscription_plan?).and_return(true)
				get_payment_details_path(group).should == view_payment_details_group_subscriptions_path(group)
			end
		end
		context 'group does not yet have a subscription plan' do
			it 'returns the path to the payment details page' do
				group.stub(:has_subscription_plan?).and_return(false)
				get_payment_details_path(group).should == new_group_subscription_path(group)
			end
		end
	end
end
