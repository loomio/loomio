angular.module('loomioApp').factory 'AnnouncementRecordsInterface', (BaseRecordsInterface, AnnouncementModel) ->
  class AnnouncementRecordsInterface extends BaseRecordsInterface
    model: AnnouncementModel

    fetchNotified: (fragment) ->
      @fetch
        path: 'notified'
        params:
          q: fragment
          per: 5

    buildFromModel: (model) ->
      @build
        announceableId:   model.id
        announceableType: _.capitalize model.constructor.singular
