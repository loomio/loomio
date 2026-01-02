class StanceReceipt < ApplicationRecord
  belongs_to :voter, class_name: 'User'
  belongs_to :inviter, class_name: 'User', optional: true
  belongs_to :revoker, class_name: 'User', optional: true
  belongs_to :poll
end
