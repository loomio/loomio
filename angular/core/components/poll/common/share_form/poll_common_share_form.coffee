angular.module('loomioApp').directive 'pollCommonShareForm', (Records, AppConfig, FormService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/share_form/poll_common_share_form.html'
  controller: ($scope) ->
    Records.polls.fetchKey().then (data) ->
      $scope.poll.key = data.key
      $scope.poll.url = "#{AppConfig.baseUrl}/#{$scope.poll.key}"

    $scope.clearPollType = ->
      $scope.poll.pollType = null

    $scope.setCommunity = ->
      if $scope.poll.public
        $scope.poll.communitiesAttributes = [{community_type: 'public'}]
      else
        $scope.poll.communitiesAttributes = [{community_type: 'email'}]
