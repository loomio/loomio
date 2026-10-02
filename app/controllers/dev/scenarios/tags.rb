module Dev::Scenarios::Tags
  def setup_member_discussion_with_restricted_tags
    group = create_group
    group.update!(members_can_create_tags: false)
    group.tags.create!(name: 'Existing', color: '#1565c0')
    group.tags.create!(name: 'Other', color: '#2e7d32')
    template = DiscussionTemplate.create!(group: group, author: patrick, process_name: 'Tagged thread', process_subtitle: 'Start a thread with an existing tag', tags: ['Existing'])
    sign_in emilio
    redirect_to "/d/new?template_id=#{template.id}&group_id=#{group.id}"
  end

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
    discussion = DiscussionService.create(params: {group_id: group.id, title: 'This thread is public', private: false}, actor: patrick)
    tag = group.tags.create(name: "Tag Name", color: "#cccccc")
    discussion_tag = discussion.discussion_tags.create(tag: tag)
    redirect_to discussion_path(discussion)
  end

  def visit_tags_page
    group = Group.create!(name: 'Open Dirty Dancing Shoes', group_privacy: 'open')
    group.add_admin! patrick
    discussion = DiscussionService.create(params: {group_id: group.id, title: 'This thread is public', private: false}, actor: patrick)
    tag = group.tags.create(name: "Tag Name", color: "#cccccc")
    discussion_tag = discussion.discussion_tags.create(tag: tag)
    redirect_to "/g/#{group.key}/tags"
  end
end
