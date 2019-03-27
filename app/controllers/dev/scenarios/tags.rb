module Dev::Scenarios::Tags
  def setup_discussion_with_tag
    tag = Tag.create(name: "Tag Name", color: "#cccccc", group: create_discussion.group)
    sign_in patrick
    redirect_to discussion_url(create_discussion)
  end

  def setup_inbox_with_tag
    tag = Tag.create(name: "Tag Name", color: "#cccccc", group: create_discussion.group)
    discussion_tag = DiscussionTag.create(discussion: create_discussion, tag: tag)
    sign_in patrick
    redirect_to inbox_url
  end

  def view_discussion_as_visitor_with_tags
    group = FormalGroup.create!(name: 'Open Dirty Dancing Shoes', group_privacy: 'open', enable_experiments: true)
    group.add_admin! patrick
    discussion = group.discussions.create!(title: 'This thread is public', private: false, author: patrick)
    tag = group.tags.create(name: "Tag Name", color: "#cccccc")
    discussion_tag = discussion.discussion_tags.create(tag: tag)
    redirect_to discussion_url(discussion)
  end

  def visit_tags_page
    group = FormalGroup.create!(name: 'Open Dirty Dancing Shoes', group_privacy: 'open', enable_experiments: true)
    group.add_admin! patrick
    discussion = group.discussions.create!(title: 'This thread is public', private: false, author: patrick)
    tag = group.tags.create(name: "Tag Name", color: "#cccccc")
    discussion_tag = discussion.discussion_tags.create(tag: tag)
    redirect_to "/tags/#{tag.id}"
  end
end
