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
    @belongsTo 'event'

  totalNotified: ->
    _.sum @notified, (n) ->
      switch n.type
        when 'FormalGroup' then n.notified_ids.length
        when 'User'        then 1
        when 'Invitation'  then 1

  eventForNotifiedDefault: ->
    @event() or @recordStore.events.build
      kind: "#{@modelType.toLowerCase()}_announced"
      eventableId:   @modelId
      eventableType: @modelType

  recipients: ->
    @model().announcementRecipients()

  model: ->
    if @event()
      @event().model()
    else
      @recordStore["#{@modelType.toLowerCase()}s"].find(@modelId)

  modelName: ->
    @model().constructor.singular
