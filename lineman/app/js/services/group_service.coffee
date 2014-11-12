angular.module('loomioApp').factory 'GroupService', ($http, RestfulService, RecordStoreService) ->
  new class GroupService extends RestfulService
    resource_plural: 'groups'

    fetchByParent: (parent, success, failure) ->
      @fetch({parent_id: parent.id}, success, failure, 'subgroups')
