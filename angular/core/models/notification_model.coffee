angular.module('loomioApp').factory 'NotificationModel', (BaseModel) ->
  class NotificationModel extends BaseModel
    @singular: 'notification'
    @plural: 'notifications'

    relationships: ->
      @belongsTo 'event'
      @belongsTo 'user'

    actor:      -> @event().actor()
    model:      -> @event().model()
    kind:       -> @event().kind

    group: ->
      switch @model().constructor.singular
        when 'group' then @model()
        else              @model().group()

    discussion: ->
      switch @model().constructor.singular
        when 'discussion' then @model()
        else                   @model().discussion()

    actionModel: ->
      if @model().constructor.singular == 'membership'
        @model().group()
      else
        @model()

    actionPath: ->
      switch @kind()
        when 'motion_closed', 'motion_closed_by_user' then 'outcome'
        when 'invitation_accepted'                    then @actor().username
