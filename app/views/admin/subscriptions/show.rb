# frozen_string_literal: true

class Views::Admin::Subscriptions::Show < Views::Admin::Layout
  def initialize(subscription:)
    super(title: "Subscription ##{subscription.id}")
    @subscription = subscription
  end

  def view_template
    page_header("Subscription ##{@subscription.id}", action_label: "Edit subscription", action_path: edit_admin_subscription_path(@subscription))
    panel("Subscription attributes") do
      definition_list(@subscription, subscription_keys) do |key, attribute|
        if key == :chargify_subscription_id && attribute.present? && ENV['CHARGIFY_APP_NAME'].present?
          link_to attribute.to_s, "https://#{ENV.fetch('CHARGIFY_APP_NAME')}.chargify.com/subscriptions/#{attribute}", target: "_blank", rel: "noopener noreferrer"
        else
          value(attribute)
        end
      end
    end
    panel("Groups") do
      ul(class: "admin-list") do
        @subscription.groups.each { |group| li { link_to group.name, admin_group_path(group) } }
      end
    end
    if @subscription.chargify_subscription_id.present?
      panel("Operations") do
        button_to "Refresh from Chargify", refresh_admin_subscription_path(@subscription), method: :post, class: "admin-button", form: { data: { confirm: "Refresh this subscription from Chargify?" } }
      end
    end
  end

  private

  def subscription_keys
    %i[id plan state expires_at renews_at renewed_at chargify_subscription_id payment_method owner_id max_threads max_members max_orgs allow_guests allow_subgroups info created_at updated_at]
  end
end
