class EventSerializer < ActiveModel::Serializer
  SUPPORTED_EVENTABLES = ['Comment', 'Motion']

  attributes :id, :sequence_id, :kind, :eventable

  def eventable
    object.eventable if SUPPORTED_EVENTABLES.include?(object.eventable.class.to_s)
  end
end
