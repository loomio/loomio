angular.module('loomioApp').factory 'NotificationModel', (BaseModel) ->
  class NotificationModel extends BaseModel
    @singular: 'notification'
    @plural: 'notifications'

    createdAt: ->
      @event().createdAt

    event: ->
      @recordStore.events.find(@eventId)

    user: ->
      @recordStore.users.find(@userId)

