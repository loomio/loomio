class GroupSurvey < ApplicationRecord
  belongs_to :group, class_name: 'FormalGroup', foreign_key: :group_id
  # has_one :subscription, through: :group, source: :subscription
end
