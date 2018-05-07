Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

{ applyLoadingFunction } = require 'shared/helpers/apply'

$controller = ($rootScope, $routeParams) ->

  @init = =>
    return if @user
    if @user = (Records.users.find($routeParams.key) or Records.users.find(username: $routeParams.key))[0]
      EventBus.broadcast $rootScope, 'currentComponent', {title: @user.name, page: 'userPage'}
      @loadGroupsFor(@user)

  @canContactUser = ->
    AbilityService.canContactUser(@user)

  @contactUser = ->
    ModalService.open 'ContactRequestModal', user: => @user

  @loadGroupsFor = (user) ->
    Records.memberships.fetchByUser(user)
  applyLoadingFunction(@, 'loadGroupsFor')

  @init()
  Records.users.findOrFetchById($routeParams.key).then @init, (error) ->
    EventBus.broadcast $rootScope, 'pageError', error

  return

$controller.$inject = ['$rootScope', '$routeParams']
angular.module('loomioApp').controller 'UserPageController', $controller
