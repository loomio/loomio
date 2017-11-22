angular.module('loomioApp').factory 'AnnouncementRecordsInterface', (BaseRecordsInterface, AnnouncementModel) ->
  class AnnouncementRecordsInterface extends BaseRecordsInterface
    model: AnnouncementModel

    fetchNotified: (fragment) ->
      @fetch
        path: 'notified'
        params:
          q: fragment
          per: 5

    fetchNotifiedDefault: (model, kind) ->
      @fetch
        path: 'notified_default'
        params:
          kind: kind
          "#{model.constructor.singular}_id": model.id

    buildFromModel: (model) ->
      @build
        kind: kind
        announceableId:   model.id
        announceableType: _.capitalize model.constructor.singular
