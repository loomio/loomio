angular.module('loomioApp').directive 'discussionsCard', ->
  scope: {group: '=', pageWindow: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/discussions_card/discussions_card.html'
  replace: true
  controller: ($scope, $location, Records, ModalService, DiscussionForm, ThreadQueryService,  KeyEventService, LoadingService, AbilityService) ->
    $scope.threadLimit = $scope.pageWindow.current
    $scope.init = ->
      $scope.discussions = ThreadQueryService.groupQuery($scope.group, filter: 'all', queryType: 'all')
    $scope.init()
    $scope.$on 'subgroupsLoaded', $scope.init

    $scope.loadMore = ->
      current = $scope.pageWindow.current
      $scope.pageWindow.current += $scope.pageWindow.pageSize
      $scope.threadLimit        += $scope.pageWindow.pageSize
      Records.discussions.fetchByGroup($scope.group.key, from: current, per: $scope.pageWindow.pageSize)

    LoadingService.applyLoadingFunction $scope, 'loadMore'
    $scope.loadMore()

    $scope.canLoadMoreDiscussions = ->
      $scope.pageWindow.current < $scope.pageWindow.max

    $scope.openDiscussionForm = ->
      ModalService.open DiscussionForm,
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
