class Contact < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :name, :email, :source, :user_id
end
