angular.module('loomioApp').factory 'NotificationModel', (BaseModel) ->
  class NotificationModel extends BaseModel
    plural: 'notifications'

    hydrate: (data) ->
      @eventId = data.event_id
      @userId = data.user_id
      @viewedAt = data.viewed_at

    createdAt: ->
      @event().createdAt

    event: ->
      @recordStore.events.get(@eventId)

    user: ->
      @recordStore.users.get(@userId)

