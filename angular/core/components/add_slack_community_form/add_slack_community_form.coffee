angular.module('loomioApp').directive 'addSlackCommunityForm', (Records, Session, LoadingService) ->
  templateUrl: 'generated/components/add_slack_community_form/add_slack_community_form.html'
  controller: ($scope) ->
    $scope.slack = {}

    $scope.fetchSlackChannels = ->
      Records.identities.perform(Session.user().slackIdentity().id, 'channels').then (response) ->
        $scope.allSlackChannels = response.channels
    LoadingService.applyLoadingFunction $scope, 'fetchSlackChannels'
    $scope.fetchSlackChannels()

    $scope.slackChannels = ->
      _.filter $scope.allSlackChannels, (channel) ->
          _.isEmpty($scope.slack.fragment) or channel.name.match(///#{$scope.slack.fragment}///i)
