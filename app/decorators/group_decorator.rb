class GroupDecorator < ApplicationDecorator
  decorates :group
  decorates_association :parent

  def link
    link = h.link_to model.name, model
  end

  def fancy_name(show_parent_name=true)
    if model.parent && show_parent_name
      parent_name = h.sanitize(model.parent.name)
      separator = h.content_tag :span, "\u25B6", class: 'name-separator'
      group_name = h.sanitize(model.name)
      name = "#{parent_name} #{separator} #{group_name}".html_safe
    else
      name = model.name
    end
    name
  end

  def fancy_link(show_parent_name=true)
    if model.parent && show_parent_name
      parent_link = parent.link
      separator = h.content_tag :span, "\u25B6", class: 'name-separator'
      group_link = link
      result = "#{parent_link} #{separator} #{group_link}".html_safe
    else
      result = link
    end
    result
  end
end
