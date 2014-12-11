class EventableSerializer < ActiveModel::Serializer
  has_one :event, serializer: EventSerializer, root: 'events'

  def event
    scope[:event]
  end

  def include_event?
    scope[:event].present?
  end

  private

  def scope
    @scope ||= options[:scope] || {}
  end
end
