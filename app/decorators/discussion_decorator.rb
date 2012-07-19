class DiscussionDecorator < ApplicationDecorator
  decorates :discussion

  # Display the discussion group name
  # this_group = the page this method is called from
  def display_group_name(this_group)
    if not this_group
      h.content_tag :div, id: "group-name" do
        GroupDecorator.new(discussion.group).fancy_name
      end
    elsif model.group_id != this_group.id
      h.content_tag :div, discussion.group.name, id: "group-name"
    end
  end
end
