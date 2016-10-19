require 'redcarpet/strip_down'

class Metadata::DiscussionSerializer < ActiveModel::Serializer
  attributes :title, :description, :image_url
  root false

  def description
    Redcarpet::Markdown.new(Redcarpet::Render::StripDown).render(object.description)
  end

  def image_url
    object.group.logo.url
  end
end
