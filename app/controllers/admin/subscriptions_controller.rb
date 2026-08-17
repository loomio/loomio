# frozen_string_literal: true

class Admin::SubscriptionsController < Admin::BaseController
  before_action :load_subscription, only: %i[show edit update refresh]

  def index
    subscriptions, pagination = paginate(filtered_subscriptions)
    render Views::Admin::Subscriptions::Index.new(subscriptions: subscriptions, pagination: pagination, filters: filter_params)
  end

  def show
    render Views::Admin::Subscriptions::Show.new(subscription: @subscription)
  end

  def edit
    render Views::Admin::Subscriptions::Edit.new(subscription: @subscription)
  end

  def update
    if @subscription.update(subscription_params)
      redirect_to admin_subscription_path(@subscription), notice: "Subscription updated"
    else
      render Views::Admin::Subscriptions::Edit.new(subscription: @subscription), status: :unprocessable_entity
    end
  end

  def refresh
    subscription_service.update(
      subscription: @subscription,
      params: subscription_service.chargify_get(@subscription.chargify_subscription_id)
    )
    redirect_to admin_subscription_path(@subscription), notice: "Subscription refreshed"
  end

  private

  def load_subscription
    @subscription = Subscription.find(params[:id])
  end

  def filtered_subscriptions
    relation = Subscription.includes(:groups).order(created_at: :desc)
    filters = filter_params
    relation = relation.where(chargify_subscription_id: filters[:chargify_id]) if filters[:chargify_id].present?
    relation = relation.where(plan: filters[:plan]) if filters[:plan].present?
    relation = relation.where(state: filters[:state]) if filters[:state].present?
    relation = relation.where(payment_method: filters[:payment_method]) if filters[:payment_method].present?
    relation = relation.where(expires_at: Date.parse(filters[:expires_from])..) if filters[:expires_from].present?
    relation = relation.where(expires_at: ..Date.parse(filters[:expires_to]).end_of_day) if filters[:expires_to].present?
    relation
  rescue Date::Error
    relation
  end

  def filter_params
    params.permit(:chargify_id, :plan, :state, :payment_method, :expires_from, :expires_to, :page, :commit).except(:page, :commit)
  end

  def subscription_params
    params.require(:subscription).permit(
      :plan, :payment_method, :state, :expires_at, :max_threads, :max_members,
      :max_orgs, :allow_guests, :allow_subgroups, :chargify_subscription_id, :owner_id
    )
  end

  def subscription_service
    SubscriptionService
  end
end
