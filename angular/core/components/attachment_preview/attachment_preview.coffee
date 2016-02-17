angular.module('loomioApp').directive 'attachmentPreview', ->
  scope: { attachment: '=', mode: '@'}
  restrict: 'E'
  templateUrl: 'generated/components/attachment_preview/attachment_preview.html'
  replace: true
  controller: ($scope, $rootScope) ->
    $scope.destroy = (event) ->
      $rootScope.$broadcast('attachmentRemoved', $scope.attachment.id)
      $scope.attachment.destroy()
      event.preventDefault()

    $scope.location = ->
      $scope.attachment[$scope.mode]
