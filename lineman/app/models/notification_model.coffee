angular.module('loomioApp').factory 'NotificationModel', (BaseModel) ->
  class NotificationModel extends BaseModel
    @singular: 'notification'
    @plural: 'notifications'

    relationships: ->
      @belongsTo 'event'
      @belongsTo 'user'

    createdAt: ->
      @event().createdAt

    actor: ->
      @event().actor()

    kind: ->
      @event().kind

    relevantRecord: ->
      @event().relevantRecord()
