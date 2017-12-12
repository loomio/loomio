angular.module('loomioApp').directive 'discussionsCard', ->
  scope: {group: '=', pageWindow: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/discussions_card/discussions_card.html'
  replace: true
  controller: ($scope, $location, Records, ModalService, DiscussionModal, ThreadQueryService,  KeyEventService, LoadingService, AbilityService) ->
    $scope.threadLimit = $scope.pageWindow.current

    $scope.init = (filter) ->
      $scope.filter = filter or 'show_open'
      $scope.pinned      = ThreadQueryService.queryFor
        name: "group_#{$scope.group.key}_pinned"
        group: $scope.group
        filters: ['show_pinned', filter]
        overwrite: true
      $scope.discussions = ThreadQueryService.queryFor
        name: "group_#{$scope.group.key}_unpinned"
        group: $scope.group
        filters: ['hide_pinned', filter]
        overwrite: true
      $scope.loadMore()

    $scope.loadMore = ->
      current = $scope.pageWindow.current
      $scope.pageWindow.current += $scope.pageWindow.pageSize
      $scope.threadLimit        += $scope.pageWindow.pageSize
      Records.discussions.fetchByGroup $scope.group.key,
        from:   current
        per:    $scope.pageWindow.pageSize
        filter: $scope.filter

    LoadingService.applyLoadingFunction $scope, 'loadMore'
    $scope.init($location.search().filter)
    $scope.$on 'subgroupsLoaded', -> $scope.init()

    $scope.canLoadMoreDiscussions = ->
      $scope.pageWindow.current < $scope.pageWindow.max

    $scope.openDiscussionModal = ->
      ModalService.open DiscussionModal,
                        discussion: -> Records.discussions.build(groupId: $scope.group.id)

    $scope.showThreadsPlaceholder = ->
      AbilityService.canStartThread($scope.group) and
      $scope.group.discussions().length < 4

    $scope.whyImEmpty = ->
      if !AbilityService.canViewGroup($scope.group)
        'discussions_are_private'
      else if !$scope.group.hasDiscussions
        'no_discussions_in_group'
      else if $scope.group.discussionPrivacyOptions == 'private_only'
        'discussions_are_private'
      else
        'no_public_discussions'

    $scope.howToGainAccess = ->
      if !$scope.group.hasDiscussions
        null
      else if $scope.group.membershipGrantedUpon == 'request'
        'join_group'
      else if $scope.group.membershipGrantedUpon == 'approval'
        'request_membership'
      else if $scope.group.membersCanAddMembers
        'membership_is_invitation_only'
      else
        'membership_is_invitation_by_admin_only'

    $scope.canStartThread = ->
      AbilityService.canStartThread($scope.group)
