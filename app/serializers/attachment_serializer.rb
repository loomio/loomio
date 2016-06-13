class AttachmentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :attachable_id, :attachable_type, :filename, :filetype, :filesize, :original, :thread, :context, :thumb, :created_at, :is_an_image?

  has_one :author, serializer: UserSerializer, root: :users

  def thread # attachments for comment body
    object[:location] || object.file.url(:thread)
  end

  def context # attachments for discussion context
    object[:location] || object.file.url(:thread)
  end

  def thumb
    object[:location] || object.file.url(:thumb)
  end
end
