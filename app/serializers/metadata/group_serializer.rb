require 'redcarpet/render_strip'

class Metadata::GroupSerializer < ActiveModel::Serializer
  attributes :title, :description, :image_urls
  root false

  def title
    object.full_name
  end

  def description
    if object.is_visible_to_public?
      Redcarpet::Markdown.new(Redcarpet::Render::StripDown).render(object.description.to_s)
    end
  end

  def image_urls
    [object.group.cover_photo.url, object.group.logo.url]
  end
end
