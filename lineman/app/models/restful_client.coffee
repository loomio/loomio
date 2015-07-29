angular.module('loomioApp').factory 'RestfulClient', ($http, $upload) ->
  AngularRecordStore.RestfulClient($http, $upload)
