class Attachment < ActiveRecord::Base
  belongs_to :user
  belongs_to :comment, counter_cache: true

  validates_presence_of :filename, :location, :user_id

  before_destroy :delete_from_storage

  alias_method :author, :user
  alias_method :author=, :user=
  #alias_method :author_id, :user_id
  #alias_method :author_id=, :user_id=

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

  def delete_from_storage
    storage = Fog::Storage.new({aws_access_key_id: Rails.application.secrets.aws_access_key_id,
                                aws_secret_access_key: Rails.application.secrets.aws_secret_access_key,
                                provider: 'AWS'})

    bucket = storage.directories.get(Rails.application.secrets.aws_bucket)
    filename = URI.decode(URI(URI.encode(self.location)).path).gsub(/^\//, '')
    file = bucket.files.get(filename)

    file.destroy if file
    true # return no true no matter what.
  end

end


