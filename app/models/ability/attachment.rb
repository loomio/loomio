module Ability::Attachment
  def initialize(user)
    super(user)

    can :show, Attachment do |attachment|
      user.groups.exists?(attachment.group_id)
    end

    can :destroy, Attachment do |attachment|
      user.adminable_groups.exists?(attachment.group_id)
    end
  end
end
