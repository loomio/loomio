angular.module('loomioApp').directive 'addSlackCommunityForm', (Records, Session, LoadingService) ->
  templateUrl: 'generated/components/add_slack_community_form/add_slack_community_form.html'
  controller: ($scope) ->
    $scope.slack = {}

    $scope.$watch 'community.customFields.slack_channel_id', ->
      return unless $scope.community.customFields.slack_channel_id
      $scope.community.customFields.slack_channel_name = _.find($scope.allSlackChannels, (channel) ->
        $scope.community.customFields.slack_channel_id == channel.id
      ).name

    $scope.fetchSlackChannels = ->
      Records.identities.perform(Session.user().slackIdentity().id, 'channels').then (response) ->
        $scope.allSlackChannels = response.channels
    LoadingService.applyLoadingFunction $scope, 'fetchSlackChannels'
    $scope.fetchSlackChannels()

    alreadyOnPoll = (channel) ->
      _.find $scope.poll.communities(), (community) ->
        community.customFields.slack_channel_id == channel.id

    $scope.slackChannels = ->
      _.filter $scope.allSlackChannels, (channel) ->
        !alreadyOnPoll(channel) and
        (_.isEmpty($scope.slack.fragment) or channel.name.match(///#{$scope.slack.fragment}///i))
