class PollReference < ApplicationRecord
   belongs_to :poll, required: true
   belongs_to :reference, polymorphic: true, required: true
end
