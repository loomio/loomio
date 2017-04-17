angular.module('loomioApp').directive 'pollCommonPublishSlackPreview', ->
  scope: {community: '=', poll: '=', message: '='}
  templateUrl: 'generated/components/poll/common/publish/slack_preview/poll_common_publish_slack_preview.html'
  controller: ($scope, $translate, Session) ->
    $scope.userName  = Session.user().name
    $scope.timestamp = -> moment().format('h:ma')
