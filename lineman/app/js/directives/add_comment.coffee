angular.module('loomioApp').directive 'addComment', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/add_comment.html'
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
