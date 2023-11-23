class MemberEmailAlias < ApplicationRecord
  belongs_to :user
  belongs_to :group
  belongs_to :author

  scope :blocked, -> { where(user_id: nil) }
  scope :allowed, -> { where.not(user_id: nil) }
end
