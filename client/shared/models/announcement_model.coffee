BaseModel = require 'shared/record_store/base_model'
AppConfig = require 'shared/services/app_config'

module.exports = class AnnouncementModel extends BaseModel
  @singular: 'announcement'
  @plural: 'announcements'

  defaultValues: ->
    recipients: []

  serialize: ->
    "#{@modelName()}_id": @model.id
    announcement:
      kind: @kind
      recipients:
        user_ids: _.compact _.map @recipients, (r) -> r.id    if     r.id
        emails:   _.compact _.map @recipients, (r) -> r.email unless r.id

  modelName: ->
    @model.constructor.singular
