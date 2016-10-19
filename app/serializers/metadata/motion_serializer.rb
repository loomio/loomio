require 'redcarpet/strip_down'

class Metadata::MotionSerializer < ActiveModel::Serializer
  attributes :title, :description
  root false

  def title
    object.name
  end

  def description
    Redcarpet::Markdown.new(Redcarpet::Render::StripDown).render(object.description)
  end

end
