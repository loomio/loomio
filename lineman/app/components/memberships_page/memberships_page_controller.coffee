angular.module('loomioApp').controller 'MembershipsPageController', ($routeParams, Records, LoadingService, AbilityService) ->
  $rootScope.$broadcast('currentComponent', { page: 'membershipsPage'})

  @loadedCount = 0
  @membershipsPerPage = 25

  Records.groups.findOrFetchByKey($routeParams.key).then (group) =>
    @group = group
    @loadMore()

  @userIsAdmin = =>
    AbilityService.canAdministerGroup(@group)

  @loadMore = =>
    Records.memberships.fetch({group_key: $routeParams.key, from: @loadedCount, per: @membershipsPerPage }).then =>
      @loadedCount = @loadedCount + @membershipsPerPage
  LoadingService.applyLoadingFunction @, 'loadMore'

  @toggleMembershipAdmin = (membership) ->
    if membership.admin
      membership.removeAdmin()
    else
      membership.makeAdmin()

  @canLoadMore = =>
    @loadedCount < @group.membershipsCount

  return
