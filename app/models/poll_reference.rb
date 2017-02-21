class PollReference < ActiveRecord::Base
   belongs_to :poll, required: true
   belongs_to :reference, polymorphic: true, required: true
end
