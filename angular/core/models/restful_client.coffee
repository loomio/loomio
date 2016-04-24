angular.module('loomioApp').factory 'RestfulClient', ($http, $upload, AppConfig) ->
  client = AngularRecordStore.RestfulClientFn($http, $upload)
  client.prototype.apiPrefix = [AppConfig.mobileHost] + '/' + client.prototype.apiPrefix if AppConfig.mobileHost
  client
