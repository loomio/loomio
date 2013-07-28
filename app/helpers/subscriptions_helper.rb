module SubscriptionsHelper
	def get_payment_details_path(group)
		if group.has_subscription_plan? == true
			view_payment_details_group_subscriptions_path(group)
		else
			new_group_subscription_path(group)
		end
	end
end
