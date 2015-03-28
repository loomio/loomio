angular.module('loomioApp').directive 'attachment', ->
  scope: {attachment: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/comment/attachment.html'
  replace: true
