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
    @build
      modelType: model.eventableType || _.capitalize(model.constructor.singular)
      modelId:   model.eventableId || model.id
      kind:      model.kind || "#{model.constructor.singular}_announced"
