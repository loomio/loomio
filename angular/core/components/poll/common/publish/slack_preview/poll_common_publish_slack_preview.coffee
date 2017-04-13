angular.module('loomioApp').directive 'pollCommonPublishSlackPreview', ->
  scope: {community: '=', poll: '='}
  templateUrl: 'generated/components/poll/common/publish/slack_preview/poll_common_publish_slack_preview.html'
