app = angular.module 'loomioApp'

app.directive 'addComment', ->
  restrict: 'E'
  templateUrl: 'next/templates/add_comment'
  replace: true
  require: '^DiscussionController'
  controller: 'AddCommentController',
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

app.service 'addCommentService',
  class AddComment
    constructor: (@$http) ->
    add: (comment) -> @$http.post('/api/comments', comment)

app.controller 'AddCommentController', ($scope, addCommentService) ->
  $scope.isExpanded = false
  $scope.comment = {}

  $scope.expand = ->
    $scope.isExpanded = true

  $scope.collapseIfEmpty = ->
    if ($scope.commentField.val().length == 0)
      $scope.isExpanded = false

  $scope.processForm = ->
    addCommentService.add($scope.comment)


