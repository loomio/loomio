class SubscriptionPortalController < ApplicationController
  before_action :authenticate_user!

  def index
    groups = current_user.adminable_groups.published.parents_only.order(:full_name)
    return redirect_to subscription_portal_group_path(groups.first.id) if groups.one?

    render Views::Subscriptions::ChooseGroup.new(groups: groups)
  end

  def show
    redirect_to_service(adminable_group)
  rescue Subscriptions::Client::Error, Subscriptions::Registration::Error
    render Views::Subscriptions::Unavailable.new, status: :bad_gateway
  end

  def manage
    group = adminable_group
    return redirect_to "/upgrade/#{group.id}" unless group.subscription&.payment_method == "loomio_subscriptions"

    redirect_to_service(group)
  rescue Subscriptions::Client::Error, Subscriptions::Registration::Error
    render Views::Subscriptions::Unavailable.new, status: :bad_gateway
  end

  private

  def adminable_group
    current_user.adminable_groups.published.parents_only.find(params[:group_id])
  end

  def redirect_to_service(group)
    Subscriptions::Registration.new.register!
    redirect_to Subscriptions::Client.new.create_session(
      group: group,
      user: current_user,
      callback_url: api_s1_webhook_url,
      return_url: group_url(group)
    ), allow_other_host: true
  end
end
