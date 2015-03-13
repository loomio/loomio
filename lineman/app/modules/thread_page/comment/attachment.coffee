angular.module('loomioApp').directive 'attachment', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/thread_page/comment/attachment.html'
  replace: true
