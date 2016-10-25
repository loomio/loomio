require 'redcarpet/render_strip'

class Metadata::GroupSerializer < ActiveModel::Serializer
  attributes :title, :description, :image_url
  root false

  def title
    object.full_name
  end

  def description
    Redcarpet::Markdown.new(Redcarpet::Render::StripDown).render(object.description.to_s)
  end

  def image_url
    object.logo.url
  end
end
