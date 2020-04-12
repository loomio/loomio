class Webhook < ApplicationRecord
  belongs_to :group
  validates_presence_of :name, :url
end
