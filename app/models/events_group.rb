class EventsGroup < ActiveRecord::Base
  belongs_to :event
  belongs_to :group
end
