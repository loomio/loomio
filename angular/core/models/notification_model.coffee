angular.module('loomioApp').factory 'NotificationModel', (BaseModel, $translate) ->
  class NotificationModel extends BaseModel
    @singular: 'notification'
    @plural: 'notifications'
    @memoize: ['content']

    relationships: ->
      @belongsTo 'event'
      @belongsTo 'user'
      @belongsTo 'actor', from: 'users'

    content: ->
      $translate.instant("notifications.#{@kind}", @translationValues)

    actionPath: ->
      switch @kind()
        when 'invitation_accepted'                    then @actor().username
