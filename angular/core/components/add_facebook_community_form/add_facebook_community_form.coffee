angular.module('loomioApp').directive 'addFacebookCommunityForm', (Records, LoadingService, Session) ->
  templateUrl: 'generated/components/add_facebook_community_form/add_facebook_community_form.html'
  controller: ($scope) ->
    $scope.facebook = {}

    $scope.fetchFacebookGroups = ->
      Records.identities.perform(Session.user().facebookIdentity().id, 'admin_groups').then (response) ->
        $scope.allFacebookGroups = response.admin_groups
    LoadingService.applyLoadingFunction $scope, 'fetchFacebookGroups'
    $scope.fetchFacebookGroups()

    $scope.facebookGroups = ->
      _.filter $scope.allFacebookGroups, (group) ->
          _.isEmpty($scope.facebook.fragment) or channel.name.match(///#{$scope.facebook.fragment}///i)
