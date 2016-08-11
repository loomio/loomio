angular.module('loomioApp').directive 'attachmentPreview', ->
  scope: { attachment: '=', mode: '@'}
  restrict: 'E'
  templateUrl: 'generated/components/attachment_preview/attachment_preview.html'
  replace: true
  controller: ($scope, $rootScope) ->
    $scope.destroy = (event) ->
      $scope.$emit('attachmentRemoved', $scope.attachment)
      event.preventDefault()

    $scope.location = ->
      $scope.attachment[$scope.mode]

    $scope.displayMode = ->
      _.contains ['thread', 'context'], $scope.mode
