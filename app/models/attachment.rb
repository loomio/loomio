class Attachment < ActiveRecord::Base
  belongs_to :user
  belongs_to :attachable, polymorphic: true

  has_attached_file :file, styles: lambda { |file| file.instance.is_an_image? ? { thumb: '100x100#', thread: '600x>' } : {} }
  do_not_validate_attachment_file_type :file

  validates :user_id, presence: true

  alias_method :author, :user
  alias_method :author=, :user=

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
    (file_content_type.try(:split, '/') || filename.try(:split, '.')).last.downcase
  end

  def filename
    super || file_file_name
  end

  def filesize
    super || file_file_size
  end

  def location
    self[:location] || file.url(:original)
  end
  alias :original :location

end
