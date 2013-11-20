app = angular.module('loomioApp', [])

app.directive 'addComment', ->
  restrict: 'E'
  templateUrl: 'next/templates/add_comment'
  replace: true
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

angular.module('loomioApp').controller 'AddCommentController', ($scope) ->
  $scope.isExpanded = false

  $scope.expand = () ->
    $scope.isExpanded = true

  $scope.collapseIfEmpty = () ->
    if ($scope.commentField.val().length == 0)
      $scope.isExpanded = false

angular.module('loomioApp').factory 'addComment', ($resource) ->
  class Comment
    constructor: (discussionId) ->
      @service = $resource '/api/discussions/:discussion_id/comments/:id',
        {discussion_id: discussionId, id: '@id'}

    create: (attrs) ->
      new @service(comment: attrs).$save (comment) ->
        attrs.id = comment.id
      attrs

    all: ->
      @service.query()
