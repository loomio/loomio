BaseModel = require 'shared/record_store/base_model.coffee'
AppConfig = require 'shared/services/app_config.coffee'

module.exports = class AnnouncementModel extends BaseModel
  @singular: 'announcement'
  @plural: 'announcements'
  @indices: ['id', 'userId']
  @serializableAttributes: AppConfig.permittedParams.announcement

  defaultValues: ->
    notified: []

  relationships: ->
    @belongsTo 'user'

  totalNotified: ->
    _.sum @notified, (n) ->
      switch n.type
        when 'FormalGroup' then n.notified_ids.length
        when 'User'        then 1
        when 'Invitation'  then 1

  model: ->
    @recordStore["#{@announceableType.toLowerCase()}s"].find(@announceableId)
