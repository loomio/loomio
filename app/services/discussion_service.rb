class DiscussionService
  def self.create(discussion:, actor:)
    discussion.author = actor
    discussion.inherit_group_privacy!
    return false unless discussion.valid?

    actor.ability.authorize! :create, discussion
    discussion.save!
    Events::NewDiscussion.publish!(discussion)
  end

  def self.update(discussion:, params:, actor:)
    actor.ability.authorize! :update, discussion

    [:private, :title, :description, :uses_markdown].each do |attr|
      discussion.send("#{attr}=", params[attr]) if params.has_key?(attr)
    end

    if actor.ability.can? :update, discussion.group
      discussion.iframe_src = params[:iframe_src]
    end

    return false unless discussion.valid?

    if discussion.title_changed?
      Events::DiscussionTitleEdited.publish!(discussion, actor)
    end

    if discussion.description_changed?
      Events::DiscussionDescriptionEdited.publish!(discussion, actor)
    end
    discussion.save!

    DiscussionReader.for(discussion: discussion, user: actor).follow!
  end
end
