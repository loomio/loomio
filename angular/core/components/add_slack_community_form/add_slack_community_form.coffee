angular.module('loomioApp').directive 'addSlackCommunityForm', (Records, Session, CommunityService, LoadingService) ->
  scope: {community: '='}
  templateUrl: 'generated/components/add_slack_community_form/add_slack_community_form.html'
  controller: ($scope) ->
    $scope.slack = {}

    $scope.$watch 'community.customFields.slack_channel_id', ->
      return unless $scope.community.customFields.slack_channel_id
      $scope.community.customFields.slack_channel_name = _.find($scope.allSlackChannels, (channel) ->
        $scope.community.customFields.slack_channel_id == channel.id
      ).name

    $scope.fetchAccessToken = ->
      CommunityService.fetchAccessToken 'slack'

    $scope.fetchSlackChannels = ->
      Records.identities.perform($scope.community.identityId, 'channels').then (response) ->
        $scope.allSlackChannels = response.channels
    LoadingService.applyLoadingFunction $scope, 'fetchSlackChannels'
    $scope.fetchSlackChannels()

    $scope.slackChannels = ->
      _.filter $scope.allSlackChannels, (channel) ->
        !CommunityService.alreadyOnPoll($scope.community.poll(), channel) and
        (_.isEmpty($scope.slack.fragment) or channel.name.match(///#{$scope.slack.fragment}///i))

    $scope.submit = CommunityService.submitCommunity $scope, $scope.community

    $scope.back = ->
      CommunityService.back($scope.community.poll())
