BaseRecordsInterface = require 'shared/record_store/base_records_interface'
AnnouncementModel    = require 'shared/models/announcement_model'

kindForTarget = (target) ->
  if _.contains(['poll_edited', 'discussion_edited'], target.kind)
    target.kind
  else
    "#{eventableOrSelf(target).constructor.singular}_announced"

eventableOrSelf = (model) ->
  if model.isA?('event')
    model.model()
  else
    model


module.exports = class AnnouncementRecordsInterface extends BaseRecordsInterface
  model: AnnouncementModel

  search: (query, model) ->
    params = {q: query}
    params.group_id = model.id if model.constructor.type == 'FormalGroup'
    @remote.fetch
      path: 'search'
      params: params

  buildFromModel: (target) ->
    @build
      kind:  kindForTarget(target)
      model: eventableOrSelf(target)

  fetchAudience: (model, kind) ->
    @remote.fetch
      path: 'audience'
      params:
        "#{model.constructor.singular}_id": model.id
        kind: kind
