BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'
AnnouncementModel    = require 'shared/models/announcement_model.coffee'

module.exports = class AnnouncementRecordsInterface extends BaseRecordsInterface
  model: AnnouncementModel

  search: (query, model) ->
    params = {q: query}
    params.group_id = model.id if model.constructor.type == 'FormalGroup'
    @remote.fetch
      path: 'search'
      params: params

  buildFromModel: (target) ->
    model = if target.constructor.singular == 'event'
      target.model()
    else
      target
    @build
      model:     model
      kind:      target.kind || "#{model.constructor.singular}_announced"

  fetchAudience: (model, kind) ->
    @remote.fetch
      path: 'audience'
      params:
        "#{model.constructor.singular}_id": model.id
        kind: kind
