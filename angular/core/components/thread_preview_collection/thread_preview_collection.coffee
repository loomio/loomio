angular.module('loomioApp').directive 'threadPreviewCollection', ->
  scope: {query: '=', limit: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/thread_preview_collection/thread_preview_collection.html'
  replace: true
  controller: ($scope, $translate) ->
    $scope.importance = (thread) ->
      multiplier = if thread.hasActiveProposal() and thread.starred then -100000
      else if         thread.hasActiveProposal() then -10000
      else if         thread.starred then -1000
      else            -1
      multiplier * thread.lastActivityAt

    $scope.translations =
      dismiss:   $translate.instant('dashboard_page.dismiss')
      mute:      $translate.instant('volume_levels.mute')
      unmute:    $translate.instant('volume_levels.unmute')
      undecided: $translate.instant('dashboard_page.thread_preview.undecided')
