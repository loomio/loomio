angular.module('loomioApp').controller 'GroupPageController', ($rootScope, $location, $routeParams, Records, CurrentUser, MessageChannelService, AbilityService, AppConfig, ModalService, SubscriptionSuccessModal, GroupWelcomeModal, LegacyTrialExpiredModal) ->
  $rootScope.$broadcast 'currentComponent', {page: 'groupPage'}

  # allow for chargify reference, which comes back #{groupKey}|#{timestamp}
  $routeParams.key = $routeParams.key.split('|')[0]
  Records.groups.findOrFetchById($routeParams.key).then (group) =>
    @group = group
    $rootScope.$broadcast 'currentComponent', { page: 'groupPage' }
    $rootScope.$broadcast 'viewingGroup', @group
    $rootScope.$broadcast 'setTitle', @group.fullName
    $rootScope.$broadcast 'analyticsSetGroup', @group

    if AbilityService.isLoggedIn()
      $rootScope.$broadcast 'trialIsOverdue', @group if @group.trialIsOverdue()
      MessageChannelService.subscribeToGroup(@group)
      Records.drafts.fetchFor(@group)
      @handleSubscriptionSuccess()
      @handleWelcomeModal()
      LegacyTrialExpiredModal.showIfAppropriate(@group, CurrentUser)
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  @showDescriptionPlaceholder = ->
    !@group.description

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
      @subscriptionSuccess = true
      @group.subscriptionKind = 'paid' # incase the webhook is slow
      $location.search 'chargify_success', null
      ModalService.open SubscriptionSuccessModal

  @showWelcomeModel = ->
    @group.isParent() and
    AbilityService.isCreatorOf(@group) and
    @group.noInvitationsSent() and
    !@group.trialIsOverdue() and
    !@subscriptionSuccess and
    !GroupWelcomeModal.shownToGroup[@group.id]

  @handleWelcomeModal = =>
    if @showWelcomeModel()
      GroupWelcomeModal.shownToGroup[@group.id] = true
      ModalService.open GroupWelcomeModal

  return
