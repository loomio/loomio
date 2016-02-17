angular.module('loomioApp').factory 'DraftRecordsInterface', (BaseRecordsInterface, DraftModel) ->
  class DraftRecordsInterface extends BaseRecordsInterface
    model: DraftModel

    findOrBuildFor: (model) ->
      _.first(@find(draftableType: _.capitalize(model.constructor.singular), draftableId: model.id)) or
      @build(draftableType: _.capitalize(model.constructor.singular), draftableId: model.id, payload: {})

    fetchFor: (model) ->
      @remote.get "#{model.constructor.singular}/#{model.id}"
