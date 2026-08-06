class SetCurrentProPlanMemberLimits < ActiveRecord::Migration[8.0]
  PLAN_NAMES_PRO = %w[2024-pro-annual 2024-pro-monthly].freeze
  PLAN_NAMES_PRO_NONPROFIT = %w[2024-pro-nonprofit-annual 2024-pro-nonprofit-monthly].freeze

  def up
    set_member_limit(PLAN_NAMES_PRO, from: nil, to: 3000)
    set_member_limit(PLAN_NAMES_PRO_NONPROFIT, from: nil, to: 300)
  end

  def down
    set_member_limit(PLAN_NAMES_PRO, from: 3000, to: nil)
    set_member_limit(PLAN_NAMES_PRO_NONPROFIT, from: 300, to: nil)
  end

  private

  def set_member_limit(plan_names, from:, to:)
    subscription = Class.new(ActiveRecord::Base) do
      self.table_name = "subscriptions"
    end

    subscription.where(plan: plan_names, max_members: from).update_all(max_members: to)
  end
end
