angular.module('loomioApp').factory 'NotificationModel', (BaseModel) ->
  class NotificationModel extends BaseModel
    @singular: 'notification'
    @plural: 'notifications'

    relationships: ->
      @belongsTo 'event'
      @belongsTo 'user'

    actor: -> @event().actor()
    model: -> @event().model()
    kind:  -> @event().kind

    actionPath: ->
      switch @kind()
        when 'motion_closed', 'motion_closed_by_user' then 'outcome'
        when 'invitation_accepted'                    then @actor().username
