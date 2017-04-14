angular.module('loomioApp').directive 'pollCommonPublishFacebookPreview', ->
  scope: {community: '=', poll: '=', message: '='}
  templateUrl: 'generated/components/poll/common/publish/facebook_preview/poll_common_publish_facebook_preview.html'
  controller: ($scope, $location) ->
    $scope.host = -> $location.host()
