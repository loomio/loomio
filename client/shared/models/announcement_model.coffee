BaseModel = require 'shared/record_store/base_model.coffee'
AppConfig = require 'shared/services/app_config.coffee'

module.exports = class AnnouncementModel extends BaseModel
  @singular: 'announcement'
  @plural: 'announcements'
  @indices: ['id', 'userId']
  @serializableAttributes: AppConfig.permittedParams.announcement

  defaultValues: ->
    recipients: []

  relationships: ->
    @belongsTo 'user'
    @belongsTo 'event'

  totalInvited: ->
    0

  model: ->
    if @event()
      @event().model()
    else
      @recordStore["#{@modelType.toLowerCase()}s"].find(@modelId)

  modelName: ->
    @model().constructor.singular
