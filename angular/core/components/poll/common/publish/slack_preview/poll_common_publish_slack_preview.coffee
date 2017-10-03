angular.module('loomioApp').directive 'pollCommonPublishSlackPreview', (AppConfig, $translate, Session) ->
  scope: {community: '=', poll: '=', message: '='}
  templateUrl: 'generated/components/poll/common/publish/slack_preview/poll_common_publish_slack_preview.html'
  controller: ($scope) ->
    $scope.siteName = AppConfig.theme.site_name
    $scope.userName  = Session.user().name
    $scope.timestamp = -> moment().format('h:ma')
