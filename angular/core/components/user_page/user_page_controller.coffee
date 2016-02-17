angular.module('loomioApp').controller 'UserPageController', ($rootScope, $routeParams, Records, LoadingService) ->
  $rootScope.$broadcast 'currentComponent', {page: 'userPage'}

  @init = =>
    return if @user
    if @user = (Records.users.find($routeParams.key) or Records.users.find(username: $routeParams.key))[0]
      @loadGroupsFor(@user.key)

  @loadGroupsFor = (userKey) ->
    Records.memberships.fetchByUser(userKey)
  LoadingService.applyLoadingFunction @, 'loadGroupsFor'

  @init()
  Records.users.findOrFetchById($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  return
