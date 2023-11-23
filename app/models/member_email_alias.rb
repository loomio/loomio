class MemberEmailAlias < ApplicationRecord
  belongs_to :user
  belongs_to :group
  belongs_to :author
end
