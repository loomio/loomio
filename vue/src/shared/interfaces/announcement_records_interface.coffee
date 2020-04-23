import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import AnnouncementModel    from '@/shared/models/announcement_model'
import {includes, merge} from 'lodash-es'

kindForTarget = (target) ->
  if includes(['poll_edited', 'discussion_edited'], target.kind)
    target.kind
  else
    "#{eventableOrSelf(target).constructor.singular}_announced"

eventableOrSelf = (model) ->
  if model.isA?('event')
    model.model()
  else
    model


export default class AnnouncementRecordsInterface extends BaseRecordsInterface
  model: AnnouncementModel

  fetchHistoryFor: (model) ->
    params = model.namedId()

    @remote.fetch
      path: 'history'
      params: params

  search: (query, model) ->
    params = merge({q: query}, model.namedId())

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
