class Attachment < ActiveRecord::Base
  belongs_to :user
  belongs_to :comment, counter_cache: true

  validates_presence_of :filename, :location, :user_id

  def is_an_image?
    extension = self.filename.split('.').last.downcase
    %w[jpg jpeg png].include?(extension)
  end
end


