class AttachmentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :attachable_id, :attachable_type, :filename, :filetype, :filesize, :original, :thread, :context, :thumb, :created_at, :is_an_image?

  # TODO: Add polymorphic attachment parent
  has_one :author, serializer: UserSerializer, root: 'users'

  def thread
    object[:location] || object.file.url(:thread)
  end
  alias :context :thread

  def thumb
    object[:location] || object.file.url(:thumb)
  end
end
