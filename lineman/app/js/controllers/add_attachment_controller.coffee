angular.module('loomioApp').controller 'AddAttachmentController', ($scope, AttachmentService, AttachmentModel) ->

  $scope.upload = ($files) ->
    $scope.isAttaching = true
    for file in $files
      $scope.uploadingFilename = file.name
      AttachmentService.upload(file, $scope.progress, $scope.success, $scope.failure)

  $scope.success = (attachment) ->
    $scope.comment.newAttachmentIds.push attachment.id
    $scope.reset()

  $scope.failure = (error) ->
    $scope.reset()
    console.log "Error: " + error

  $scope.progress = (progress) ->
    $scope.percentComplete = Math.floor(100 * progress.loaded / progress.total)

  $scope.reset = ->
    $scope.isAttaching = false
    $scope.percentComplete = 0
    $scope.uploadingFilename = ''
  $scope.reset()

  $scope.remove = (attachment) ->
    AttachmentService.remove(attachment.id)
