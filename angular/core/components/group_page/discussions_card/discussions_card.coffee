angular.module('loomioApp').directive 'discussionsCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/discussions_card/discussions_card.html'
  replace: true
  controller: ($scope, Records, ModalService, DiscussionForm, ThreadQueryService,  KeyEventService, LoadingService, AbilityService, CurrentUser) ->
    $scope.loaded = 0
    $scope.perPage = 25
    $scope.canLoadMoreDiscussions = true
    $scope.discussions = []

    $scope.updateDiscussions = (data = {}) ->
      $scope.discussions = ThreadQueryService.groupQuery($scope.group, { filter: 'all', queryType: 'all' })
      if (data.discussions or []).length < $scope.perPage
        $scope.canLoadMoreDiscussions = false

    $scope.loadMore = ->
      options =
        from:     $scope.loaded
        per:      $scope.perPage
      $scope.loaded += $scope.perPage
      Records.discussions.fetchByGroup($scope.group.key, options).then $scope.updateDiscussions, -> $scope.canLoadMoreDiscussions = false

    LoadingService.applyLoadingFunction $scope, 'loadMore'
    $scope.loadMore()

    $scope.openDiscussionForm = ->
      ModalService.open DiscussionForm,
                        discussion: -> Records.discussions.build(groupId: $scope.group.id)

    $scope.showThreadsPlaceholder = ->
      AbilityService.canAdministerGroup($scope.group) and $scope.group.discussions().length < 3

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

    $scope.isMemberOfGroup = ->
      CurrentUser.membershipFor($scope.group)?
