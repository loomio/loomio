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

    actionModel: ->
      switch @kind()
        when 'new_coordinator', 'user_added_to_group', 'membership_request_approved' then @model().group()
        else                                                                              @model()

    actionPath: ->
      switch @kind()
        when 'motion_closed', 'motion_closed_by_user' then 'outcome'
        when 'invitation_accepted'                    then @actor().username
