class GroupFollow < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :user_id, uniqueness: { scope: :group_id }
  validate :user_is_not_a_group_member

  private

  def user_is_not_a_group_member
    return unless user && group
    return unless group.members.exists?(user.id)

    errors.add(:user, :invalid)
  end
end
