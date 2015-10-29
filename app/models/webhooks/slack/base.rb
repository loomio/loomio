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
    I18n.t :"webhooks.slack.#{event.kind}", author: author.name, name: proposal_link(eventable)
  end

  def attachments
    [{
      title:       attachment_title,
      text:        attachment_text,
      fields:      attachment_fields,
      fallback:    attachment_fallback,
      color:       attachment_color
    }]
  end

  def attachment_color
  end

  alias :read_attribute_for_serialization :send

  private

  def motion_vote_field
    {
      title: "Have your say",
      value: "#{proposal_link(eventable, "yes")} · " +
             "#{proposal_link(eventable, "abstain")} · " +
             "#{proposal_link(eventable, "no")} · " +
             "#{proposal_link(eventable, "block")}"
    }
  end

  def view_motion_on_loomio
    view_discussion_on_loomio({ proposal: eventable.key })
  end

  def view_discussion_on_loomio(params = {})
    { value: discussion_link(I18n.t(:"webhooks.slack.view_it_on_loomio"), params) }
  end

  def proposal_link(model, position = nil)
    discussion_link position_text_for(position) || proposal_name(model), { proposal: model.key, position: position }
  end

  def discussion_link(text = nil, params = {})
    "<#{discussion_url(eventable.discussion, params)}|#{text || eventable.discussion.title}>"
  end

  def position_text_for(position)
    case position
    when 'yes' then 'agree'
    when 'abstain' then 'abstain'
    when 'no' then 'no'
    when 'block' then 'block'
    end
  end

  def eventable
    @eventable ||= event.eventable
  end

  def proposal_name(model)
    case model
    when Motion then model.name
    when Vote then model.motion_name
    end
  end

  def author
    @author ||= eventable.author
  end

end
