class Contact < ApplicationRecord
  belongs_to :user
  validates_presence_of :name, :email, :source, :user_id

  scope :search_for, ->(query) { where(":query = '' or name ilike :query or email ilike :query", query: "%#{query}%") }

end
