angular.module('loomioApp').factory 'BaseRecordsInterface', (RestfulClient, $q) ->
  AngularRecordStore.BaseRecordsInterface(RestfulClient, $q)
