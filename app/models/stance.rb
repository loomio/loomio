class Stance < ActiveRecord::Base
  belongs_to :poll, required: true
  belongs_to :poll_option, required: true
  belongs_to :participant, polymorphic: true, required: true
end
