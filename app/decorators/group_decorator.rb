class GroupDecorator < ApplicationDecorator
  decorates :group

  def full_link
    link_text = model.name
    link_text = "#{model.parent.name} > #{model.name}" if model.parent
    link = h.link_to link_text, model
  end

  def link
    link = h.link_to model.name, model
  end
end
