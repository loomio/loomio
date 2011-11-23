class Motion < ActiveRecord::Base
  belongs_to :group
  belongs_to :author, :class_name => 'User'
  belongs_to :facilitator, :class_name => 'User'
  validates_presence_of :name, :group, :author, :facilitator_id
end
