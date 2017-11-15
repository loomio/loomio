angular.module('loomioApp').factory 'AnnouncementModel', (BaseModel, AppConfig) ->
  class AnnouncementModel extends BaseModel
    @singular: 'announcement'
    @plural: 'announcements'
    @indices: ['id', 'userId']
    @serializableAttributes: AppConfig.permittedParams.announcement

    defaultValues: ->
      notified: []

    relationships: ->
      @belongsTo 'user'

    model: ->
      @recordStore["#{@announceableType.toLowerCase()}s"].find(@announceableId)
