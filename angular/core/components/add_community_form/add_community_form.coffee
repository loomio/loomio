angular.module('loomioApp').directive 'addCommunityForm', ($window, $location, Records, Session) ->
  scope: {poll: '='}
  replace: true
  templateUrl: 'generated/components/add_community_form/add_community_form.html'
  controller: ($scope) ->

    $scope.addFacebook = (confirm) ->
      if Session.user().facebookIdentityId
        Records.identities.perform(Session.user().facebookIdentityId, 'admin_groups')
      else
        $scope.fetchAccessToken('facebook')

    $scope.addSlack = (confirm) ->
      if Session.user().slackIdentityId
        Records.identities.perform(Session.user().slackIdentityId, 'channels')
      else
        $scope.fetchAccessToken('slack')

    $scope.fetchAccessToken = (type) ->
      delete $location.search().share
      $location.search().add_community = type
      $window.location = "#{type}/oauth"

    $scope.cancel = ->
      delete $scope.showConfirmation

    $scope.identityIdFor = (type) ->
      Session.user()["#{type}IdentityId"]
