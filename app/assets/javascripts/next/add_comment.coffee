app = angular.module 'loomioApp'

app.directive 'addComment', ->
  restrict: 'E'
  templateUrl: 'next/templates/add_comment'
  replace: true
  controller: 'AddCommentController'
  link: (scope, element, attrs) ->
    fakeRow = element.find('.fake.card-row')
    realRow = element.find('.real.card-row')

    fakeInput = element.find('.fake input')
    realInput = element.find('.real textarea')

    scope.commentField = element.find('.real textarea')

    scope.$watch 'isExpanded', (isExpanded) ->
      if isExpanded
        fakeRow.addClass('ng-hide')
        realRow.removeClass('ng-hide')
        realInput.focus()
      else
        fakeRow.removeClass('ng-hide')
        realRow.addClass('ng-hide')

app.controller 'AddCommentController', ($scope, addCommentService) ->
  $scope.isExpanded = false

  $scope.expand = ->
    $scope.isExpanded = true

  $scope.collapseIfEmpty = ->
    if ($scope.commentField.val().length == 0)
      $scope.isExpanded = false

  $scope.processForm = () ->
    addCommentService.add($scope.comment, $scope.discussion)


app.service 'addCommentService',
  class AddComment
    constructor: (@$http) ->
    # i am here.. then append to discussion?
    add: (comment, discussion) ->
      @$http.post('/api/comments', comment).then (response) ->
        discussion.events.push response.data




