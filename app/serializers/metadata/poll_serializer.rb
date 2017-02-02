require 'redcarpet/render_strip'

class Metadata::PollSerializer < ActiveModel::Serializer
  attributes :title, :description
  root false

  def title
    object.title
  end

  def description
    Redcarpet::Markdown.new(Redcarpet::Render::StripDown).render(object.details.to_s)
  end

end
