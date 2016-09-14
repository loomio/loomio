class SubscriptionsController < ApplicationController

  def select_gift_plan
    group = Group.find_by!(key: params[:group_key])
    SubscriptionService.new(group).start_gift_unless_paying!
    render html: I18n.t('subscriptions.gift_plan_selected_for_group_html', group: group.full_name, group_key: group.key).html_safe
  end

  def webhook
    if SubscriptionService.available?
      case params[:event].try(:to_sym)
      when :signup_success              then subscription_service.start_subscription!(subscription_params['id'].to_i)
      when :subscription_product_change then subscription_service.change_plan!(subscription_params['product']['handle'])
      when :subscription_state_change   then subscription_service.end_subscription! if subscription_params['state'] == 'canceled'
      end
      head :ok
    else
      head :bad_request
    end
  end

  private

  def subscription_service
    @subscription_service ||= SubscriptionService.new(group_from_reference, group_from_reference.creator)
  end

  def subscription_params
    @subscription_params ||= params['payload']['subscription']
  end

  def group_from_reference
    @group_from_reference ||= Group.find(subscription_params['customer']['reference'].split('-')[0])
  end
end
