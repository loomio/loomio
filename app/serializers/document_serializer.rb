class DocumentSerializer < ApplicationSerializer
  attributes :id, :title, :icon, :color, :url,
             :web_url, :thumb_url, :model_id, :model_type,
             :created_at, :group_id, :manual_url

  has_one :author, serializer: AuthorSerializer, root: :users

  def group_id
    object.group&.id
  end

  def manual_url
    object.manual_url?
  end

  def is_an_image?
    object.doctype == 'image'
  end
  alias :include_web_url? :is_an_image?
  alias :include_thumb_url? :is_an_image?
end
