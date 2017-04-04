angular.module('loomioApp').directive 'threadPreviewCollection', ->
  scope: {query: '=', limit: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/thread_preview_collection/thread_preview_collection.html'
  replace: true
  controller: ($scope) ->
    $scope.importance = (thread) ->
      if      thread.starred and thread.hasDecision() then -3
      else if thread.hasDecision()                    then -2
      else if thread.starred                          then -1
      else                                                  0
