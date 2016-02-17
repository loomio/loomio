angular.module('loomioApp').directive 'attachmentForm', ->
  scope: {comment: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/comment_form/attachment_form.html'
  replace: true
  controller: ($scope, $rootScope, $timeout, Records) ->
    $scope.upload = (files) ->
      for file in files
        $rootScope.$broadcast 'disableCommentForm'
        $scope.currentUpload = Records.attachments.upload(file, $scope.progress)
        $scope.currentUpload.then($scope.success).finally($scope.reset)

    $scope.selectFile = ->
      $timeout -> document.querySelector('.attachment-form__file-input').click()

    $scope.progress = (progress) ->
      $scope.percentComplete = Math.floor(100 * progress.loaded / progress.total)

    $scope.abort = ->
      $scope.currentUpload.abort() if $scope.currentUpload

    $scope.success = (response) ->
      data = response.data || response
      _.each data.attachments, (attachment) ->
        $scope.comment.newAttachmentIds.push(attachment.id)

    $scope.reset = ->
      $scope.files = $scope.currentUpload = null
      $scope.percentComplete = 0
      $rootScope.$broadcast 'enableCommentForm'
    $scope.reset()
