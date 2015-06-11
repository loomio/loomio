angular.module('loomioApp').controller 'GroupPageController', ($rootScope, $scope, $routeParams, $document, $timeout, Records, MessageChannelService, CurrentUser, ScrollService, ModalService) ->
  $rootScope.$broadcast 'currentComponent', {page: 'groupPage'}
  $scope.$on 'newGroupCreated', -> ModalService.openModal 'groupIntro'

  Records.groups.findOrFetchByKey($routeParams.key).then (group) =>
    @group = group
    $rootScope.$broadcast('setTitle', @group.fullName())
    MessageChannelService.subscribeTo("/group-#{@group.key}")
    ScrollService.scrollTo('h1:first')
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  @isMember = ->
    CurrentUser.membershipFor(@group)?

  @joinGroup = ->
    Records.memberships.initialize(
      group_id: @group.id
      user_id: CurrentUser.id).save()

  @showDescriptionPlaceholder = ->
    CurrentUser.isAdminOf(@group) and !@group.description
  
  return
