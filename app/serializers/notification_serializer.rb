class NotificationSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :viewed, :created_at, :url, :kind, :translation_values

  def kind
    case object.kind
    when 'announcement_created' then object.eventable.kind
    else                             object.kind
    end
  end

  has_one :actor, serializer: UserSerializer, root: :users

  def actor
    if object.kind == 'stance_created'
      object.eventable.participant_for_client
    else
      object.actor
    end
  end
end
