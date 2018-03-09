class Announcee < ApplicationRecord
  belongs_to :announcement, required: true
  belongs_to :announceable, required: true, polymorphic: true
end
