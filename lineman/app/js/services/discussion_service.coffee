angular.module('loomioApp').factory 'DiscussionService', ($http, RestfulService, RecordStoreService) ->
  new class DiscussionService extends RestfulService
    resource_plural: 'discussions'
