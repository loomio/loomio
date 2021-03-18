module Ability::Attachment
  def initialize(user)
    super(user)

    can :show, ::Attachment do |attachment|
      user.groups.exists?(attachment.record.group.id)
    end

    can :destroy, ::Attachment do |attachment|
      user.adminable_groups.exists?(attachment.record.group.id)
    end
  end
end
