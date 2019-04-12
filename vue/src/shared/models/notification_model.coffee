import BaseModel    from '@/shared/record_store/base_model'

export default class NotificationModel extends BaseModel
  @singular: 'notification'
  @plural: 'notifications'

  relationships: ->
    @belongsTo 'event'
    @belongsTo 'user'
    @belongsTo 'actor', from: 'users'

  actionPath: ->
    switch @kind()
      when 'invitation_accepted' then @actor().username
