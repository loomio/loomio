angular.module('loomioApp').controller 'DiscussionsController', ($scope, $modal, DiscussionService, Records) ->
  DiscussionService.fetchByGroup $scope.group

  nextPage = 1
  busy = false
  $scope.lastPage = false

  $scope.getNextPage = ->
    return false if busy or $scope.lastPage
    busy = true
    DiscussionService.fetchByGroup $scope.group, nextPage, (discussions) ->
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
          Records.discussions.new(group_id: $scope.group.id)
