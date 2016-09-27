angular.module('loomioApp').controller 'GroupPageController', ($rootScope, $location, $routeParams, $scope, Records, Session, MessageChannelService, AbilityService, AppConfig, LmoUrlService, PaginationService, ModalService, SubscriptionSuccessModal, GroupWelcomeModal, ChoosePlanModal) ->
  $rootScope.$broadcast 'currentComponent', {page: 'groupPage', key: $routeParams.key}

  $scope.$on 'joinedGroup', => @handleWelcomeModal()

  # allow for chargify reference, which comes back #{groupKey}|#{timestamp}
  # we include the timestamp so chargify sees unique values
  $routeParams.key = $routeParams.key.split('-')[0]
  Records.groups.findOrFetchById($routeParams.key).then (group) =>
    @group = group

    if AbilityService.isLoggedIn()
      MessageChannelService.subscribeToGroup(@group)

      @handleChoosePlanModal()
      @handleSubscriptionSuccess()
      @handleWelcomeModal()

    Records.drafts.fetchFor(@group) if AbilityService.canCreateContentFor(@group)

    maxDiscussions = if AbilityService.canViewPrivateContent(@group)
      @group.discussionsCount
    else
      @group.publicDiscussionsCount
    @pageWindow = PaginationService.windowFor
      current:  parseInt($location.search().from or 0)
      min:      0
      max:      maxDiscussions
      pageType: 'groupThreads'

    $rootScope.$broadcast 'viewingGroup', @group
    $rootScope.$broadcast 'setTitle', @group.fullName
    $rootScope.$broadcast 'analyticsSetGroup', @group
    $rootScope.$broadcast 'currentComponent',
      page: 'groupPage'
      group: @group
      key: @group.key
      links:
        canonical:   LmoUrlService.group(@group, {}, absolute: true)
        rss:         LmoUrlService.group(@group, {}, absolute: true, ext: 'xml') if !@group.privacyIsSecret()
        prev:        LmoUrlService.group(@group, from: @pageWindow.prev)         if @pageWindow.prev?
        next:        LmoUrlService.group(@group, from: @pageWindow.next)         if @pageWindow.next?

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
    if $location.search().chargify_success?
      Session.subscriptionSuccess = true
      @group.subscriptionKind = 'paid' # incase the webhook is slow
      $location.search 'chargify_success', null
      ModalService.open SubscriptionSuccessModal

  @shouldShowChoosePlanModal = =>
    AppConfig.chargify? and
    !($location.search().chargify_success?) and
    !@group.hasSubscription() and
    @group.experiences.bx_choose_plan and
    @group.isParent() and
    Session.user().isAdminOf(@group)

  @handleChoosePlanModal = ->
    if @shouldShowChoosePlanModal()
      ModalService.open ChoosePlanModal, group: (=> @group), preventClose: (-> true)

  @shouldShowWelcomeModal = ->
    !@shouldShowChoosePlanModal() and
    @group.isParent() and
    Session.user().isMemberOf(@group) and
    !Session.subscriptionSuccess and
    !Session.user().hasExperienced("welcomeModal")


  @handleWelcomeModal = =>
    if @shouldShowWelcomeModal()
      ModalService.open GroupWelcomeModal, group: => @group
      Records.users.saveExperience("welcomeModal")

  return
