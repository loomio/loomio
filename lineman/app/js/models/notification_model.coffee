angular.module('loomioApp').factory 'NotificationModel', (RecordStoreService, BaseModel) ->
  class NotificationModel extends BaseModel
    constructor: (data = {}) ->
      @id = data.id
      @eventId = data.event_id
      @userId = data.user_id
      @viewedAt = data.viewed_at

    plural: 'notifications'

    createdAt: ->
      @event().createdAt

    event: ->
      RecordStoreService.get('events', @eventId)

    user: ->
      RecordStoreService.get('user', @userId)
