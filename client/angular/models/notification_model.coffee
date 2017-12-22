angular.module('loomioApp').factory 'NotificationModel', (BaseModel, $translate) ->
  class NotificationModel extends BaseModel
    @singular: 'notification'
    @plural: 'notifications'

    relationships: ->
      @belongsTo 'event'
      @belongsTo 'user'
      @belongsTo 'actor', from: 'users'

    actionPath: ->
      switch @kind()
        when 'invitation_accepted'                    then @actor().username
