import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import DraftModel           from '@/shared/models/draft_model'

export default class DraftRecordsInterface extends BaseRecordsInterface
  model: DraftModel

  findOrBuildFor: (model) ->
    _.head(@find(draftableType: _.capitalize(model.constructor.singular), draftableId: model.id)) or
    @build(draftableType: _.capitalize(model.constructor.singular), draftableId: model.id, payload: {})

  fetchFor: (model) ->
    @remote.get "#{model.constructor.singular}/#{model.id}"
