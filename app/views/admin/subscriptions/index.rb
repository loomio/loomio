# frozen_string_literal: true

class Views::Admin::Subscriptions::Index < Views::Admin::Layout
  def initialize(subscriptions:, pagination:, filters:)
    super(title: "Subscriptions")
    @subscriptions = subscriptions
    @pagination = pagination
    @filters = filters
  end

  def view_template
    page_header("Subscriptions")
    render_filters
    div(class: "admin-table-wrap") do
      table(class: "admin-table") do
        thead { tr { %w[Plan Groups State Expires Payment Chargify ID Owner Actions].each { |heading| th { heading } } } }
        tbody do
          @subscriptions.each do |subscription|
            tr do
              td { link_to value(subscription.plan), admin_subscription_path(subscription) }
              td { subscription.groups.map(&:name).join(", ") }
              td { value(subscription.state) }
              td { value(subscription.expires_at&.to_date) }
              td { value(subscription.payment_method) }
              td { value(subscription.chargify_subscription_id) }
              td { value(subscription.owner) }
              td { link_to "Edit", edit_admin_subscription_path(subscription) }
            end
          end
        end
      end
    end
    pagination_links(@pagination, @filters)
  end

  private

  def render_filters
    form_with(url: admin_subscriptions_path, method: :get, class: "admin-filter-bar") do |form|
      div(class: "admin-filter-bar__search") do
        form.label(:chargify_id, "Chargify subscription ID")
        form.search_field(:chargify_id, value: @filters[:chargify_id], placeholder: "Subscription ID")
      end
      field(form, :plan, value: @filters[:plan])
      field(form, :state, value: @filters[:state])
      field(form, :payment_method, value: @filters[:payment_method])
      field(form, :expires_from, type: :date_field, value: @filters[:expires_from])
      field(form, :expires_to, type: :date_field, value: @filters[:expires_to])
      form.submit("Search", class: "admin-button")
      link_to "Clear", admin_subscriptions_path, class: "admin-button admin-button--secondary"
    end
  end
end
