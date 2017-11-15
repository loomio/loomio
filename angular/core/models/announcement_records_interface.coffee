angular.module('loomioApp').factory 'AnnouncementRecordsInterface', (BaseRecordsInterface, AnnouncementModel) ->
  class AnnouncementRecordsInterface extends BaseRecordsInterface
    model: AnnouncementModel
