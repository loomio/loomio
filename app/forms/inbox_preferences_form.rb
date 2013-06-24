class InboxPreferencesForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def persisted?
    false
  end

  def initialize(user)
    @user = user
  end
  
  def submit(params)
    if valid?
      ordered_group_ids = params[:groups].reject(&:blank?).map(&:to_i)
      clear_all_groups_from_inbox
      update_inbox_positions(ordered_group_ids)
      true
    else
      false
    end
  end

  def memberships
    all_memberships.where('inbox_position is not null')
  end
  
  def all_memberships
    @user.
      memberships.
      joins(:group).
      order(:inbox_position)
  end

  def all_groups
    @user.groups.order(:full_name)
  end

  private
  def clear_all_groups_from_inbox
    @user.memberships.update_all(:inbox_position => nil)
  end

  def update_inbox_positions(ordered_group_ids)
    ordered_group_ids.each_with_index do |group_id, position|
      @user.memberships.where(group_id: group_id).first.update_attribute(:inbox_position, position)
    end
  end
end
