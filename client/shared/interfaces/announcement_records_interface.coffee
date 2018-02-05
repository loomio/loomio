BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'
AnnouncementModel    = require 'shared/models/announcement_model.coffee'

module.exports = class AnnouncementRecordsInterface extends BaseRecordsInterface
  model: AnnouncementModel

  fetchNotified: (fragment) ->
    @fetch
      path: 'notified'
      params:
        q: fragment
        per: 5

  fetchNotifiedDefault: (announcement) ->
    @fetch
      path: 'notified_default'
      params:
        kind: announcement.kind
        "#{announcement.modelType.toLowerCase()}_id": announcement.modelId

  buildFromModel: (model) ->
    switch model.constructor.singular
      when 'event' then @build(eventId: model.id)
      else              @build(modelId: model.id, modelType: _.capitalize(model.constructor.singular))
