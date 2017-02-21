angular.module('loomioApp').directive 'pollCommonAttachmentForm', (AttachmentService) ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/attachment_form/poll_common_attachment_form.html'
  replace: true
  controller: ($scope) ->
    AttachmentService.listenForAttachments $scope, $scope.poll
