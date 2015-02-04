angular.module('loomioApp').controller 'AttachmentFormController', ($scope, Records) ->
  $scope.upload = (files) ->
    for file in files
      Records.attachments.upload(file, $scope.progress, $scope.success, $scope.reset)

  $scope.abort = ->
    Records.attachments.abortUpload()

  $scope.success = (attachment) ->
    $scope.comment.newAttachmentIds.push attachment.id
    $scope.reset()

  $scope.progress = (progress) ->
    $scope.percentComplete = Math.floor(100 * progress.loaded / progress.total)

  $scope.reset = ->
    $scope.files = null
    $scope.percentComplete = 0
  $scope.reset()
