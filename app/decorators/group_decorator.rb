class GroupDecorator < ApplicationDecorator
  decorates :group

  def full_link
    link = ""
    if model.parent
      link += h.link_to model.parent.name, h.group_path(model.parent)
      link += " > "
    end
    link += h.link_to model.name, h.group_path(model)
    link.html_safe
  end

  def link
    link = h.link_to model.name, model
  end
end
