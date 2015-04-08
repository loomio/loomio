class Webhooks::SlackSerializer < ActiveModel::Serializer
  attributes :username, :text, :icon_url

  def username
    object.eventable.author.name
  end

  def text
    case object.kind
    when 'new_comment' then object.eventable.body
    when 'new_motion'  then "*#{username}* started a new proposal: #{object.eventable.name}"
    when 'new_vote'    then "*#{username}* voted '#{object.eventable.position}' on the proposal #{object.eventable.motion.name}\n#{object.eventable.statement}"
    when 'motion_closing_soon' then "#{object.eventable.name} is closing soon."
    end
  end

  def icon_url
    case object.kind
    when 'new_comment' then 'http://www.endlessicons.com/wp-content/uploads/2012/11/comment-icon.png'
    when 'new_motion' then 'http://png-1.findicons.com/files/icons/2463/glossy/512/pie_chart.png'
    when 'new_vote' then 'http://socialmediadiary.com.au/home/wp-content/uploads/2012/05/Thumbs-up.jpg'
    end
  end

end
