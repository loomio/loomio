angular.module('loomioApp').factory 'VersionRecordsInterface', (BaseRecordsInterface, VersionModel) ->
  class VersionRecordsInterface extends BaseRecordsInterface
    model: VersionModel
