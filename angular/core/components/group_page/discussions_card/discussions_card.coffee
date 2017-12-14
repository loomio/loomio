angular.module('loomioApp').directive 'discussionsCard', ($location, Records, RecordLoader, ModalService, DiscussionModal, ThreadQueryService,  KeyEventService, LoadingService, AbilityService) ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/discussions_card/discussions_card.html'
  replace: true
  controller: ($scope) ->

    $scope.init = (filter) ->
      $scope.filter = filter or 'show_opened'
      $scope.pinned = ThreadQueryService.queryFor
        name: "group_#{$scope.group.key}_pinned"
        group: $scope.group
        filters: ['show_pinned', $scope.filter]
        overwrite: true
      $scope.discussions = ThreadQueryService.queryFor
        name: "group_#{$scope.group.key}_unpinned"
        group: $scope.group
        filters: ['hide_pinned', $scope.filter]
        overwrite: true
      $scope.loader = new RecordLoader
        collection: 'discussions'
        params:
          group_id: $scope.group.id
          filter:   $scope.filter
      $scope.loader.fetchRecords()

    $scope.init($location.search().filter)
    $scope.$on 'subgroupsLoaded', -> $scope.init($scope.filter)

    $scope.openDiscussionModal = ->
      ModalService.open DiscussionModal, discussion: -> Records.discussions.build(groupId: $scope.group.id)

    $scope.isEmpty = ->
      !$scope.loader.loading && !($scope.discussions.any() || $scope.pinned.any())

    $scope.canViewPrivateContent = ->
      AbilityService.canViewPrivateContent($scope.group)

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
