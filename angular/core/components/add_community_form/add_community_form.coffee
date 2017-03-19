angular.module('loomioApp').directive 'addCommunityForm', ($window, $location, Session) ->
  scope: {poll: '='}
  replace: true
  templateUrl: 'generated/components/add_community_form/add_community_form.html'
  controller: ($scope) ->

    $scope.addCommunity = (type, confirm) ->
      if $scope.identityFor(type)
        console.log("#{type} identity found: #{$scope.identityFor(type)}")
      else if !confirm
        $scope.showConfirmation = type
      else
        delete $location.search().share
        $location.search().add_community = type
        $window.location = "#{type}/oauth"

    $scope.cancel = ->
      delete $scope.showConfirmation

    $scope.identityFor = (type) ->
      Session.user()["#{type}IdentityId"]
