class Attachment < ActiveRecord::Base
  belongs_to :user
  belongs_to :comment, counter_cache: true

  validates_presence_of :filename, :location, :user_id

  def is_an_image?
    %w[jpg jpeg png gif].include?(filetype)
  end

  def truncated_filename(length = 30)
    if filename.length > length
      filename.truncate(length) + filetype
    else
      filename
    end
  end

  def filetype
    filename.split('.').last.downcase
  end
end


