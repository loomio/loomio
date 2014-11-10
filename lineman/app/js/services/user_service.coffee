angular.module('loomioApp').factory 'UserService', ($http, RestfulService) ->
  new class UserService extends RestfulService
    resource_plural: 'users'

    fetchByNameFragment: (fragment, groupId, success, failure) ->
      @fetch({q: fragment, group_id: groupId}, success, failure, 'members')
