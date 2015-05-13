class GroupVisit < ActiveRecord::Base
  belongs_to :visit
  belongs_to :group
end
