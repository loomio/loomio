angular.module('loomioApp').controller 'GroupPageController', ($rootScope, $location, $routeParams, Records, CurrentUser, MessageChannelService, AbilityService, AppConfig, ModalService, SubscriptionSuccessModal, GroupWelcomeModal) ->
  $rootScope.$broadcast 'currentComponent', {page: 'groupPage'}

  Records.groups.findOrFetchById($routeParams.key).then (group) =>
    @group = group
    $rootScope.$broadcast 'currentComponent', { page: 'groupPage' }
    $rootScope.$broadcast 'viewingGroup', @group
    $rootScope.$broadcast 'setTitle', @group.fullName
    $rootScope.$broadcast 'analyticsSetGroup', @group
    $rootScope.$broadcast 'trialIsOverdue', @group if @group.trialIsOverdue()
    MessageChannelService.subscribeToGroup(@group)
    Records.drafts.fetchFor(@group)
    @handleSubscriptionSuccess()
    @handleWelcomeModal()
  , (error) ->
    $rootScope.$broadcast('pageError', error)

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

  @handleSubscriptionSuccess = ->
    if (AppConfig.chargify or AppConfig.environment == 'development') and $location.search().chargify_success?
      @group.subscriptionKind = 'paid' # incase the webhook is slow
      $location.search 'chargify_success', null
      ModalService.open SubscriptionSuccessModal

  @handleWelcomeModal = ->
    if CurrentUser.isAdminOf(@group) and @group.noInvitationsSent() and !@group.trialIsOverdue() and !GroupWelcomeModal.shownToGroup[@group.id]?
      GroupWelcomeModal.shownToGroup[@group.id] = true
      ModalService.open GroupWelcomeModal

  return
