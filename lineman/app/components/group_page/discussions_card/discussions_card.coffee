angular.module('loomioApp').directive 'discussionsCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/discussions_card/discussions_card.html'
  replace: true
  controller: ($scope, $modal, Records, ModalService, DiscussionForm, KeyEventService, LoadingService, CurrentUser) ->
    $scope.loaded = 0
    $scope.perPage = 25

    $scope.loadMore = ->
      options =
        group_id: $scope.group.id
        from:     $scope.loaded
        per:      $scope.perPage
      $scope.loaded += $scope.perPage
      Records.discussions.fetchByGroup options

    LoadingService.applyLoadingFunction $scope, 'loadMore'
    $scope.loadMore()

    $scope.openDiscussionForm = ->
      ModalService.open DiscussionForm,
                        discussion: -> Records.discussions.initialize(group_id: $scope.group.id)

    KeyEventService.registerKeyEvent $scope, 'pressedT', $scope.openDiscussionForm

    $scope.showThreadsPlaceholder = ->
      CurrentUser.isAdminOf($scope.group) and $scope.group.discussions().length <= 1

    $scope.whyImEmpty = ->
      if !$scope.group.hasDiscussions
        'no_discussions_in_group'
      else if $scope.group.discussionPrivacyOptions == 'private_only'
        'discussions_are_private'
      else
        'no_public_discussions'

    $scope.howToGainAccess = ->
      if !$scope.group.hasDiscussions
        null
      else if $scope.group.membershipGrantedUpon == 'approval'
       'request_membership'
      else if $scope.group.membersCanAddMembers
        'membership_is_invitation_only'
      else
        'membership_is_invitation_by_admin_only'

    $scope.requestToJoin = ->
      # will need to implement this; is it in a modal? New page?
      # also, probably wants to go in a form for accessibility
