angular.module('loomioApp').controller 'GroupPageController', ($rootScope, $routeParams, Records, CurrentUser, ScrollService, MessageChannelService, AbilityService, ModalService, CoverPhotoForm, LogoPhotoForm) ->
  $rootScope.$broadcast 'currentComponent', {page: 'groupPage'}

  Records.groups.findOrFetchById($routeParams.key).then (group) =>
    @group = group
    $rootScope.$broadcast 'currentComponent', { page: 'groupPage' }
    $rootScope.$broadcast 'viewingGroup', @group
    $rootScope.$broadcast 'setTitle', @group.fullName()
    $rootScope.$broadcast 'analyticsSetGroup', @group
    MessageChannelService.subscribeToGroup(@group)
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  @logoStyle = ->
    { 'background-image': "url(#{@group.logoUrl()})" }

  @coverStyle = ->
    { 'background-image': "url(#{@group.coverUrl()})" }

  @isMember = ->
    CurrentUser.membershipFor(@group)?

  @showDescriptionPlaceholder = ->
    AbilityService.canAdministerGroup(@group) and !@group.description

  @canManageMembershipRequests = ->
    AbilityService.canManageMembershipRequests(@group)

  @canUploadPhotos = ->
    AbilityService.canAdministerGroup(@group)

  @openUploadCoverForm = ->
    ModalService.open CoverPhotoForm, group: => @group

  @openUploadLogoForm = ->
    ModalService.open LogoPhotoForm, group: => @group

  return
