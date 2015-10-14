angular.module('loomioApp').controller 'GroupPageController', ($rootScope, $location, $routeParams, Records, CurrentUser, MessageChannelService, AbilityService, AppConfig, ModalService, SubscriptionSuccessModal) ->
  $rootScope.$broadcast 'currentComponent', {page: 'groupPage'}

  Records.groups.findOrFetchById($routeParams.key).then (group) =>
    @group = group
    $rootScope.$broadcast 'currentComponent', { page: 'groupPage' }
    $rootScope.$broadcast 'viewingGroup', @group
    $rootScope.$broadcast 'setTitle', @group.fullName
    $rootScope.$broadcast 'analyticsSetGroup', @group
    $rootScope.$broadcast 'trialIsOverdue', @group if @group.trialIsOverdue()
    MessageChannelService.subscribeToGroup(@group)
    if AppConfig.chargify and $location.search().chargify_success?
      $location.search 'chargify_success', null
      ModalService.open SubscriptionSuccessModal
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  @showDescriptionPlaceholder = ->
    AbilityService.canAdministerGroup(@group) and !@group.description

  @canManageMembershipRequests = ->
    AbilityService.canManageMembershipRequests(@group)

  @showTrialCard = ->
    @group.subscriptionKind == 'trial' and AbilityService.canAdministerGroup(@group) and AppConfig.chargify?

  @showGiftCard = ->
    @group.subscriptionKind == 'gift' and AppConfig.chargify?

  @canUploadPhotos = ->
    AbilityService.canAdministerGroup(@group)

  @openUploadCoverForm = ->
    ModalService.open CoverPhotoForm, group: => @group

  @openUploadLogoForm = ->
    ModalService.open LogoPhotoForm, group: => @group

  return
