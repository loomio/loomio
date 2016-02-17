angular.module('loomioApp').factory 'RestfulClient', ($http, $upload) ->
  AngularRecordStore.RestfulClientFn($http, $upload)
