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

  def delete_attachment
    storage = Fog::Storage.new({aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'], aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], provider: 'AWS'})
    bucket = storage.directories.get(ENV['AWS_ATTACHMENTS_BUCKET'])
    file = bucket.files.get(URI.parse(URI.encode(self.location)).path)
    file.destroy
  end
end


