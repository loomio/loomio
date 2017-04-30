angular.module('loomioApp').controller 'GroupPageController', ($rootScope, $location, $routeParams, $scope, Records, Session, MessageChannelService, AbilityService, AppConfig, LmoUrlService, PaginationService, PollService, ModalService) ->
  $rootScope.$broadcast 'currentComponent', {page: 'groupPage', key: $routeParams.key, skipScroll: true }

  @launchers = []
  @addLauncher = (action, condition = (-> true), opts = {}) =>
    @launchers.push
      priority:       opts.priority || 9999
      action:         action
      condition:      condition
      allowContinue:  opts.allowContinue

  @performLaunch = ->
    @launchers.sort((a, b) -> a.priority - b.priority).map (launcher) =>
      return if (typeof launcher.action != 'function') || @launched
      if launcher.condition()
        launcher.action()
        @launched = true unless launcher.allowContinue

  # allow for chargify reference, which comes back #{groupKey}|#{timestamp}
  # we include the timestamp so chargify sees unique values
  $routeParams.key = $routeParams.key.split('-')[0]
  Records.groups.findOrFetchById($routeParams.key).then (group) =>
    @init(group)
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  @init = (group) =>
    @group = group
    @performLaunch()
    MessageChannelService.subscribeToGroup(@group) if AbilityService.isLoggedIn()

    @usePolls = PollService.usePollsFor(@group)

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

  @canViewMemberships = ->
    AbilityService.canViewMemberships(@group)

  @canManageMembershipRequests = ->
    AbilityService.canManageMembershipRequests(@group)

  @canUploadPhotos = ->
    AbilityService.canAdministerGroup(@group)

  @openUploadCoverForm = ->
    @openModal.open CoverPhotoForm, group: => @group

  @openUploadLogoForm = ->
    @openModal LogoPhotoForm, group: => @group

  @openModal = (modal, resolve)->
    ModalService.open modal, resolve

  @showPreviousPolls = ->
    @usePolls and
    AbilityService.canViewPreviousPolls(@group) and
    @group.closedPollsCount > 0

  return
