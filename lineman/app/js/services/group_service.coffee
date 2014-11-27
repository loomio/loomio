angular.module('loomioApp').factory 'GroupService', ($http, RestfulService) ->
  new class GroupService extends RestfulService
    resource_plural: 'groups'

    fetchByParent: (parent, success, failure) ->
      @fetch({parent_id: parent.id}, success, failure, 'subgroups')

    archive: (group, success, failure) ->
      @save(group, success, failure, 'archive')
