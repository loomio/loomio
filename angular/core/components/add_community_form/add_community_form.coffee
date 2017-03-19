angular.module('loomioApp').directive 'addCommunityForm', ($window, $location, Session) ->
  scope: {poll: '='}
  replace: true
  templateUrl: 'generated/components/add_community_form/add_community_form.html'
  controller: ($scope) ->

    $scope.addCommunity = (type) ->
      if $scope.identityIdFor(type)
        console.log("#{type} identity found: #{$scope.identityIdFor(type)}")
      else
        delete $location.search().share
        $location.search().add_community = type
        $window.location = "#{type}/oauth"

    $scope.identityIdFor = (type) ->
      Session.user()["#{type}IdentityId"]
