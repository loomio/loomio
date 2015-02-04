angular.module('loomioApp').directive 'attachment', ->
  scope: {attachment: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/discussion_page/comment/attachment.html'
  replace: true
  link: (scope, element, attrs) ->
