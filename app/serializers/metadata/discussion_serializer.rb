require 'redcarpet/render_strip'

class Metadata::DiscussionSerializer < ActiveModel::Serializer
  attributes :title, :description, :image_urls
  root false

  def description
    Redcarpet::Markdown.new(Redcarpet::Render::StripDown).render(object.description.to_s)
  end

  def image_urls
    [object.group.cover_photo.url, object.group.logo.url]
  end
end
