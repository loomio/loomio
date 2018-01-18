class Theme < ApplicationRecord
  has_attached_file :pages_logo
  has_attached_file :app_logo
  validates_attachment_content_type :pages_logo, :content_type => /\Aimage\/.*\Z/
  validates_attachment_content_type :app_logo, :content_type => /\Aimage\/.*\Z/

  validates_presence_of :name
end
