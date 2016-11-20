angular.module('loomioApp').factory 'NotificationModel', (BaseModel, $translate) ->
  class NotificationModel extends BaseModel
    @singular: 'notification'
    @plural: 'notifications'

    relationships: ->
      @belongsTo 'event'
      @belongsTo 'user'
      @belongsTo 'actor', from: 'users'

    content: ->
      $translate.instant("notifications.#{@kind}", @translationValues)

    actionPath: ->
      switch @kind()
        when 'motion_closed', 'motion_closed_by_user' then 'outcome'
        when 'invitation_accepted'                    then @actor().username
