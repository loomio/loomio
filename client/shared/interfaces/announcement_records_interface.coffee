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
      model:     model.eventable()
      kind:      model.kind || "#{model.constructor.singular}_announced"

  fetchAudience: (model, kind) ->
    @remote.fetch
      path: 'audience'
      params:
        "#{model.constructor.singular}_id": model.id
        kind: kind
