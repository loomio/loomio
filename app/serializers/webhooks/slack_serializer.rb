class Webhooks::SlackSerializer < ActiveModel::Serializer
  attributes :text, :attachments, :icon_url

  def icon_url
    # need to work on these some
  end

  def text
    case object.kind
    when 'new_comment' then "*#{author.name}* commented on *#{discussion_link}*:"
    when 'new_motion'  then "*#{author.name}* created a new proposal in *#{discussion_link}*:"
    when 'new_vote'    then "*#{author.name}* #{eventable.position} on the proposal *#{discussion_link}*:"
    end
  end

  def attachments
    [{
      fallback:    fallback,
      title:       title,
      text:        attachment_text,
      fields:      fields
    }]
  end

  private

  def fallback
    case object.kind
    when 'new_comment' then "#{eventable.body}\n"
    when 'new_motion'  then "*#{eventable.name}*\n#{eventable.description}\n"
    when 'new_vote'    then "TODO"
    end
  end

  def title
    case object.kind
    when 'new_motion' then eventable.name
    when 'new_vote'   then motion.name
    end
  end

  def attachment_text
    case object.kind
    when 'new_comment' then "#{eventable.body}\n"
    when 'new_motion'  then "#{eventable.description}\n"
    when 'new_vote'    then "#{eventable.statement}\n"
    end
  end

  def fields
    case object.kind
    when 'new_comment' then [view_it_on_loomio_field]
    when 'new_motion'  then [motion_vote_field]
    when 'new_vote'    then [view_it_on_loomio_field]
    end
  end

  def motion_vote_field
    {
      title: "Vote on this proposal",
      value: "#{vote_on_this("agree")} · " +
             "#{vote_on_this("abstain")} · " +
             "#{vote_on_this("disagree")} · " +
             "#{vote_on_this("block")}"
    }
  end

  def view_it_on_loomio_field
    {value: discussion_link(text: "View it on Loomio")}
  end

  def vote_on_this(position)
    discussion_link text: position
  end

  def discussion_link(text: nil, params: {})
    "<#{discussion_url(params)}|#{text || discussion.title}>"
  end

  def discussion_url(params = {})
    Routing.discussion_url(discussion, params)
  end

  def eventable
    @eventable ||= object.eventable
  end

  def discussion
    @discussion ||= eventable.discussion
  end

  def motion
    @motion ||= eventable.motion
  end

  def author
    @author ||= eventable.author
  end

end
