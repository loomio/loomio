angular.module('loomioApp').controller 'GroupPageController', ($scope, $rootScope, $routeParams, Records, CurrentUser, ScrollService, MessageChannelService, AbilityService) ->
  $rootScope.$broadcast 'currentComponent', {page: 'groupPage'}

  Records.groups.findOrFetchById($routeParams.key).then (group) =>
    @group = group
    $rootScope.$broadcast 'currentComponent', { page: 'groupPage' }
    $rootScope.$broadcast 'viewingGroup', @group
    $rootScope.$broadcast 'setTitle', @group.fullName()
    $rootScope.$broadcast 'analyticsSetGroup', @group
    MessageChannelService.subscribeTo("/group-#{@group.key}")
    @setPhotos()
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  @setPhotos = =>
    @coverStyle = {"background-image": "url(#{@group.coverUrl()})"}
    @logoStyle = {"background-image": "url(#{@group.logoUrl()})"}
  $scope.$on 'groupPhotoUploaded', @setPhotos

  @isMember = ->
    CurrentUser.membershipFor(@group)?

  @showDescriptionPlaceholder = ->
    AbilityService.canAdministerGroup(@group) and !@group.description

  @canManageMembershipRequests = ->
    AbilityService.canManageMembershipRequests(@group)

  @canUploadPhotos = ->
    AbilityService.canAdministerGroup(@group)

  return
