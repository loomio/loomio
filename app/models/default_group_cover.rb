class DefaultGroupCover < ApplicationRecord
  has_one_attached :cover_photo

  def self.sample
    all.order(Arel.sql 'random()').first
  end

  def self.store(file)
    open(file) { |f| create! cover_photo: f }
  end
end
