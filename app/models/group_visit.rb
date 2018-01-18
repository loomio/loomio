class GroupVisit < ApplicationRecord
  belongs_to :visit
  belongs_to :group
  belongs_to :user
end
