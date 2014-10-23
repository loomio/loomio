angular.module('loomioApp').controller 'AddAttachmentController', ($scope, AttachmentService) ->

  $scope.isAttaching = false
  $scope.percentComplete = 0
  $scope.uploadingFilename = ''

  $scope.upload = ($files) ->
    $scope.isAttaching = true
    for file in $files
      $scope.uploadingFilename = file.filename
      AttachmentService.upload(file, $scope.progress, $scope.success, $scope.failure)

  $scope.success = (attachment) ->
    $scope.reset()
    $scope.comment.attachmentIds.push attachment.attachment_id
    console.log 'Upload success!'

  $scope.failure = (error) ->
    $scope.reset()
    console.log "Error: " + error

  $scope.progress = (progress) ->
    $scope.percentComplete = Math.floor(100 * progress.loaded / progress.total)

  $scope.reset = ->
    $scope.isAttaching = false
    $scope.percentComplete = 0
    $scope.uploadingFilename = ''

  $scope.remove = (attachment) ->
    AttachmentService.remove(attachment.id)
