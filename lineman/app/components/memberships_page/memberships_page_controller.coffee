angular.module('loomioApp').controller 'MembershipsPageController', ($routeParams, Records, LoadingService) ->
  @loading = true
  @loadedCount = 0
  @membershipsPerPage = 25

  Records.groups.findOrFetchByKey($routeParams.key).then (group) => @group = group

  @loadMore = =>
    Records.memberships.fetch({group_key: $routeParams.key, from: @loadedCount, per: @membershipsPerPage })
  LoadingService.applyLoadingFunction @, 'loadMore'
  @loadMore()

  @userIsAdmin = =>
    window.Loomio.currentUser.isAdminOf(@group)

  @toggleMembershipAdmin = (membership) ->
    if membership.admin
      membership.removeAdmin()
    else
      membership.makeAdmin()

  @destroyMembership = (membership) ->
    membership.destroy()

  return
