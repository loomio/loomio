Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

angular.module('loomioApp').controller 'UserPageController', ($rootScope, $routeParams, LoadingService, ModalService, ContactRequestModal) ->

  @init = =>
    return if @user
    if @user = (Records.users.find($routeParams.key) or Records.users.find(username: $routeParams.key))[0]
      $rootScope.$broadcast 'currentComponent', {title: @user.name, page: 'userPage'}
      @loadGroupsFor(@user)

  @location = =>
    @user.location || @user.detectedLocation().join(', ')

  @canContactUser = ->
    AbilityService.canContactUser(@user)

  @contactUser = ->
    ModalService.open ContactRequestModal, user: => @user

  @loadGroupsFor = (user) ->
    Records.memberships.fetchByUser(user)
  LoadingService.applyLoadingFunction @, 'loadGroupsFor'

  @init()
  Records.users.findOrFetchById($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  return
