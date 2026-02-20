module Dev::Scenarios::Tags
  def setup_discussion_with_tag
    tag = Tag.create(name: "Tag Name", color: "#cccccc", group: create_discussion.group)
    sign_in patrick
    redirect_to discussion_path(create_discussion)
  end

  def setup_inbox_with_tag
    tag = Tag.create(name: "Tag Name", color: "#cccccc", group: create_discussion.group)
    discussion_tag = DiscussionTag.create(discussion: create_discussion, tag: tag)
    sign_in patrick
    redirect_to inbox_path
  end

  def view_discussion_as_visitor_with_tags
    group = Group.create!(name: 'Open Dirty Dancing Shoes', group_privacy: 'open')
    group.add_admin! patrick
    result = DiscussionService.create(params: {group_id: group.id, title: 'This thread is public', private: false}, actor: patrick)
    discussion = result[:discussion]
    tag = group.tags.create(name: "Tag Name", color: "#cccccc")
    discussion_tag = discussion.discussion_tags.create(tag: tag)
    redirect_to discussion_path(discussion)
  end

  def visit_tags_page
    group = Group.create!(name: 'Open Dirty Dancing Shoes', group_privacy: 'open')
    group.add_admin! patrick
    result = DiscussionService.create(params: {group_id: group.id, title: 'This thread is public', private: false}, actor: patrick)
    discussion = result[:discussion]
    tag = group.tags.create(name: "Tag Name", color: "#cccccc")
    discussion_tag = discussion.discussion_tags.create(tag: tag)
    redirect_to "/g/#{group.key}/tags"
  end
end
