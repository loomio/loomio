BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'
AnnouncementModel    = require 'shared/models/announcement_model.coffee'

module.exports = class AnnouncementRecordsInterface extends BaseRecordsInterface
  model: AnnouncementModel

  fetchMembersFor: (model, expandGroup) ->
    params = {"#{model.constructor.singular}_id": model.id}
    params.expand_group = true if expandGroup?
    @fetch
      path: 'members'
      params: params

  fetchNotified: (fragment) ->
    @fetch
      path: 'notified'
      params:
        q: fragment
        per: 5

  fetchNotifiedDefault: (event) ->
    @fetch
      path: 'notified_default'
      params:
        kind: event.kind
        "#{event.eventableType.toLowerCase()}_id": event.eventableId

  buildFromModel: (model) ->
    switch model.constructor.singular
      when 'event' then @build(eventId: model.id)
      else              @build(modelId: model.id, modelType: _.capitalize(model.constructor.singular))
