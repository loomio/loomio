BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'
AnnouncementModel    = require 'shared/models/announcement_model.coffee'

module.exports = class AnnouncementRecordsInterface extends BaseRecordsInterface
  model: AnnouncementModel

  search: (query) ->
    @remote.fetch
      path: 'search'
      params:
        q: query

  buildFromModel: (model) ->
    switch model.constructor.singular
      when 'event' then @build(eventId: model.id)
      else              @build(modelId: model.id, modelType: _.capitalize(model.constructor.singular))
