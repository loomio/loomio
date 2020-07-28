class AttachmentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :filename, :content_type, :byte_size, :icon, :group_id,
             :preview_url, :download_url, :created_at

  has_one :author, serializer: AuthorSerializer, root: :users

  def author
    object.record.author
  end

  def preview_url
    Rails.application.routes.url_helpers.rails_representation_path(object.representation(HasRichText::PREVIEW_OPTIONS), only_path: true) if object.representable?
  end

  def download_url
    Rails.application.routes.url_helpers.rails_blob_path(object, disposition: "attachment", only_path: true)
  end

  def filename
    object.blob.filename
  end

  def content_type
    object.blob.content_type
  end

  def byte_size
    object.blob.byte_size
  end

  def icon
    AppConfig.doctypes.detect{ |type| /#{type['regex']}/.match(content_type || filename) }['icon']
  end

end
