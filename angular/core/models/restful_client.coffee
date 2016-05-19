angular.module('loomioApp').factory 'RestfulClient', ($http, $upload, AppConfig, LmoUrlService) ->
  client = AngularRecordStore.RestfulClientFn($http, $upload)
  client.prototype.apiPrefix = LmoUrlService.srcFor(client.prototype.apiPrefix)
  client
