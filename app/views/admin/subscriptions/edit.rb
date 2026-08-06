# frozen_string_literal: true

class Views::Admin::Subscriptions::Edit < Views::Admin::Layout
  def initialize(subscription:)
    super(title: "Edit subscription ##{subscription.id}")
    @subscription = subscription
  end

  def view_template
    page_header("Edit subscription ##{@subscription.id}")
    form_with(model: @subscription, url: admin_subscription_path(@subscription), method: :put, class: "admin-form") do |form|
      field(form, :plan)
      field(form, :payment_method)
      field(form, :state)
      field(form, :expires_at, type: :datetime_local_field)
      field(form, :max_threads, type: :number_field)
      field(form, :max_members, type: :number_field)
      field(form, :max_orgs, type: :number_field)
      checkbox_field(form, :allow_guests)
      checkbox_field(form, :allow_subgroups)
      field(form, :chargify_subscription_id)
      field(form, :owner_id, type: :number_field)
      form.submit("Save subscription", class: "admin-button")
    end
  end
end
