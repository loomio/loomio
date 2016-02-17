angular.module('loomioApp').factory 'BaseRecordsInterface', (RestfulClient, $q) ->
  AngularRecordStore.BaseRecordsInterfaceFn(RestfulClient, $q)
