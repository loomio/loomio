angular.module('loomioApp').controller 'AddAttachmentController', ($scope, $upload, AttachmentService) ->

  $scope.isAttaching = false

  $scope.upload = ($files) ->
    $scope.isAttaching = true
    for file in $files
      AttachmentService.add(file, $scope.progress, $scope.success, $scope.failure)

  $scope.removeAttachment = (id) ->
    AttachmentService.remove(id)

  $scope.success = ->
    $scope.isAttaching = false
    console.log "Success!"

  $scope.failure = (error) ->
    $scope.isAttaching = false
    console.log error

  $scope.progress = (progress) ->
    console.log "In progress:"
    console.log progress

  $scope.abort = ->
    $upload.abort()
