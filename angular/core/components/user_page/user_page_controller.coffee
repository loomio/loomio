angular.module('loomioApp').controller 'UserPageController', ($rootScope, $routeParams, Records, LoadingService) ->
  $rootScope.$broadcast 'currentComponent', {page: 'userPage'}

  @init = =>
    return if @user
    if @user = (Records.users.find($routeParams.key) or Records.users.find(username: $routeParams.key))[0]
      @loadGroupsFor(@user)

  @loadGroupsFor = (user) ->
    Records.memberships.fetchByUser(user)
  LoadingService.applyLoadingFunction @, 'loadGroupsFor'

  @init()
  Records.users.findOrFetchById($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  return
