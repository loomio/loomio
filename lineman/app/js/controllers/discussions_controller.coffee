angular.module('loomioApp').controller 'DiscussionsController', ($scope, $modal, Records, UserAuthService) ->
  nextPage = 1
  busy = false
  $scope.lastPage = false

  $scope.getNextPage = ->
    return false if busy or $scope.lastPage
    busy = true
    Records.discussions.fetchByGroupKeyAndPage $scope.group.key, nextPage, (data) ->
      discussions = data.discussions
      $scope.lastPage = true if discussions.length < 5
      nextPage = nextPage + 1
      busy = false

  $scope.getNextPage()

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
