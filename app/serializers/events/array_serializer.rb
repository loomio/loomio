class Events::ArraySerializer < ApplicationSerializer
  has_many :events, root: :events
end
