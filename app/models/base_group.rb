class BaseGroup < ActiveRecord::Base
  self.table_name = :groups

  has_many :memberships,
           -> { where is_suspended: false, archived_at: nil },
           extend: GroupMemberships

  has_many :all_memberships,
           dependent: :destroy,
           class_name: 'Membership',
           extend: GroupMemberships

  has_many :membership_requests,
           dependent: :destroy

  has_many :pending_membership_requests,
           -> { where response: nil },
           class_name: 'MembershipRequest',
           dependent: :destroy

  has_many :admin_memberships,
           -> { where admin: true, archived_at: nil },
           class_name: 'Membership',
           dependent: :destroy

  has_many :members,
           through: :memberships,
           source: :user

  has_many :pending_invitations,
           -> { where accepted_at: nil, cancelled_at: nil },
           as: :invitable,
           class_name: 'Invitation'

  has_many :invitations,
           as: :invitable,
           class_name: 'Invitation',
           dependent: :destroy

  after_create :guess_cohort
  def guess_cohort
    if self.cohort_id.blank?
      cohort_id = Group.where('cohort_id is not null').order('cohort_id desc').first.try(:cohort_id)
      self.update_attribute(:cohort_id, cohort_id) if cohort_id
    end
  end

end
