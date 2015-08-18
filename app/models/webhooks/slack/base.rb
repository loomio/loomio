Webhooks::Slack::Base = Struct.new(:event) do
  include Routing

  def username
    "Loomio Bot"
  end

  def icon_url
    # we'll host our own image soon I reckon
    "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xap1/v/t1.0-1/p50x50/11537803_694991540606106_5116967442850884451_n.jpg?oh=eeba96f797e9cb12340bfd94df2650f0&oe=56802643&__gda__=1447229045_95708238caee2d950ea43c93b38b071c"
  end

  def text
    I18n.t :"webhooks.slack.#{event.kind}", author: author.name, name: eventable_name
  end

  def attachments
    [{
      title:       attachment_title,
      text:        attachment_text,
      fields:      attachment_fields,
      fallback:    attachment_fallback
    }]
  end

  alias :read_attribute_for_serialization :send

  private

  def eventable_name
    eventable.discussion.title
  end

  def motion_vote_field
    {
      title: "Vote on this proposal",
      value: "#{vote_on_this("yes")} · " +
             "#{vote_on_this("abstain")} · " +
             "#{vote_on_this("no")} · " +
             "#{vote_on_this("block")}"
    }
  end

  def view_motion_on_loomio
    view_discussion_on_loomio({ proposal: eventable.key })
  end

  def view_discussion_on_loomio(params = {})
    { value: discussion_link(I18n.t(:"webhooks.slack.view_it_on_loomio"), params) }
  end

  def vote_on_this(position)
    discussion_link position, { proposal: eventable.key, position: position }
  end

  def discussion_link(text = nil, params = {})
    "<#{discussion_url(eventable.discussion, params)}|#{text || eventable.discussion.title}>"
  end

  def eventable
    @eventable ||= event.eventable
  end

  def author
    @author ||= eventable.author
  end

end
