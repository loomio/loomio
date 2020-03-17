module HasGuestGroup
  extend ActiveSupport::Concern
  included do
    belongs_to :guest_group, class_name: "GuestGroup", dependent: :destroy
    has_many :guests, through: :guest_group, source: :members
  end

  def groups
    [group, guest_group].compact
  end

  def guest_group
    super || create_guest_group.tap { self.save(validate: false) } if persisted?
  end

  def group_members
    User.joins(:memberships).where("memberships.group_id": group_id)
  end

  def guest_members
    guest_group.members.where.not(id: group.presence&.member_ids)
  end

  def members
    User.distinct.joins(:memberships).where("memberships.group_id": groups.map(&:id))
  end

  def accepted_members
    members.where('memberships.accepted_at IS NOT NULL')
  end
end
