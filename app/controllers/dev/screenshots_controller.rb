class Dev::ScreenshotsController < Dev::NightwatchController

  # Produces a richly-populated discussion thread for help manual screenshots.
  # Sign in as patrick (admin) so admin actions are visible.
  # Jennifer posts the final comment so there is one unread item.
  def screenshot_discussion_thread
    group = create_group
    discussion = Discussion.new(
      title: "Preparing a new sustainability service",
      description: "<h2>Background</h2><p>We've been asked to explore launching a new sustainability advisory service for our members. Before we proceed, we'd like to gather input from the team on scope, timeline, and resources.</p><p>Please share your thoughts below. We aim to have a direction by end of month.</p>",
      description_format: 'html',
      private: false,
      group: group,
      author: patrick
    )
    DiscussionService.create(discussion: discussion, actor: patrick)

    c1 = Comment.new(discussion: discussion, body: "Thanks for raising this, Patrick. I think there's real demand for this service — I've had three member enquiries in the past month alone. Happy to help scope it out.", author: jennifer)
    CommentService.create(comment: c1, actor: jennifer)

    c2 = Comment.new(discussion: discussion, body: "Agreed. I'd suggest we start with a pilot for existing members before opening it more broadly. That way we can refine the offering without overcommitting.", author: emilio)
    CommentService.create(comment: c2, actor: emilio)

    ReactionService.update(reaction: Reaction.new(reactable: c2), params: {reaction: ':thumbsup:'}, actor: patrick)
    ReactionService.update(reaction: Reaction.new(reactable: c2), params: {reaction: ':heart:'}, actor: jennifer)

    c3_body = "## Timeline proposal\n\nBased on our current capacity, here's what I think is achievable:\n\n- **Month 1** – Define scope and assemble working group\n- **Month 2** – Pilot with 5 member organisations\n- **Month 3** – Review and iterate\n\nWould love to hear if this timeline works for everyone."
    c3 = Comment.new(discussion: discussion, body: c3_body, author: patrick)
    CommentService.create(comment: c3, actor: patrick)

    # Jennifer's reply — appears unread to patrick after sign-in
    c4 = Comment.new(discussion: discussion, body: "The timeline looks reasonable to me. One thing worth noting — we'll need buy-in from the finance team before month 2. @patrickswayze can you set up a meeting with them?", parent: c3, author: jennifer)
    CommentService.create(comment: c4, actor: jennifer)

    sign_in patrick
    redirect_to discussion_path(discussion)
  end

  # Group page with open and closed discussions
  def screenshot_group_page
    create_discussion
    create_closed_discussion
    sign_in patrick
    redirect_to group_path(create_group)
  end

  # New discussion form directly (skipping templates picker)
  def screenshot_discussion_new_form
    group = create_group
    sign_in patrick
    redirect_to "/d/new?group_id=#{group.id}"
  end

  # Discussion with an edited comment — for showing comment history
  def screenshot_discussion_edited_comment
    group = create_group
    discussion = Discussion.new(title: "Preparing a new sustainability service", private: false, group: group, author: patrick)
    DiscussionService.create(discussion: discussion, actor: patrick)

    comment = Comment.new(discussion: discussion, body: "I think we should launch in Q1.", author: jennifer)
    CommentService.create(comment: comment, actor: jennifer)
    comment.update(body: "I think we should launch in Q2 — Q1 is too soon given our current workload.")
    comment.update_versions_count

    sign_in patrick
    redirect_to discussion_path(discussion)
  end

  # Discussion with moveable comments
  def screenshot_discussion_forkable
    create_discussion
    create_another_discussion
    CommentService.create(comment: Comment.new(discussion: create_discussion, body: "This is on topic — great discussion!", author: jennifer), actor: jennifer)
    event = CommentService.create(comment: Comment.new(discussion: create_discussion, body: "Slightly tangential but relevant: we should also consider the comms plan.", author: emilio), actor: emilio)
    CommentService.create(comment: Comment.new(discussion: create_discussion, body: "Agreed on the comms plan — let's start a separate thread for that.", parent: event.eventable, author: patrick), actor: patrick)
    sign_in patrick
    redirect_to discussion_path(create_discussion)
  end

  # Direct discussion new form
  def screenshot_direct_discussion
    create_group
    sign_in patrick
    redirect_to '/d/new?type=direct'
  end
end
