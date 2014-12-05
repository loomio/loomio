angular.module('loomioApp').controller 'DiscussionsCardController', ($scope, $modal, Records, UserAuthService) ->
  nextPage = 1
  busy = false
  $scope.lastPage = false

  $scope.getNextPage = ->
    return false if busy or $scope.lastPage
    busy = true
    Records.discussions.fetchByGroupAndPage($scope.group, nextPage).then (data) ->
      discussions = data.discussions
      $scope.lastPage = true if discussions.length < 5
      nextPage = nextPage + 1
      busy = false

  $scope.getNextPage()

  # hey this should send a signal to the top? open new discussion form with this group id?
  $scope.openForm = ->
    modalInstance = $modal.open
      templateUrl: 'generated/templates/discussion_form.html'
      controller: 'DiscussionFormController'
      resolve:
        discussion: ->
          Records.discussions.initialize(group_id: $scope.group.id)

  $scope.canStartDiscussions = ->
    UserAuthService.currentUser.isMemberOf($scope.group) and
      ($scope.group.membersCanStartDiscussions or UserAuthService.currentUser.isAdminOf($scope.group))
