class Announcement < ActiveRecord::Base
  belongs_to: :announceable, polymorphic: true
end
