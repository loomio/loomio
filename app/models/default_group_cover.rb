class DefaultGroupCover < ApplicationRecord
  has_attached_file :cover_photo
  validates_attachment :cover_photo, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }

  def self.sample
    all.order(Arel.sql 'random()').first
  end

  def self.store(file)
    open(file) { |f| create! cover_photo: f }
  end

end
