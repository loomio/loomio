require 'redcarpet/render_strip'

class Metadata::PollSerializer < ActiveModel::Serializer
  attributes :title, :description, :image_urls
  root false

  def title
    object.title
  end

  def description
    Redcarpet::Markdown.new(Redcarpet::Render::StripDown).render(object.details.to_s)
  end

  def image_urls
    object.group ? [object.group.cover_photo.url, object.group.logo.url] : []
  end
end
