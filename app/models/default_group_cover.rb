class DefaultGroupCover < ActiveRecord::Base
  has_attached_file :cover_photo
  validates_attachment :cover_photo, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }

  def self.sample
    all.order('random()').first
  end

  def self.store(file)
    file = open(file) if file.is_a? String
    create! cover_photo: file
  end

end
