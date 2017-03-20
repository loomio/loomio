angular.module('loomioApp').directive 'addCommunityForm', ($window, $location, Records, Session, LoadingService) ->
  templateUrl: 'generated/components/add_community_form/add_community_form.html'
  controller: ($scope) ->

    $scope.addCommunity = (type) ->
      if $scope.identity(type)
        $scope.communityForm = type
      else
        $scope.fetchAccessToken(type)

    $scope.fetchAccessToken = (type) ->
      delete $location.search().share
      $location.search('add_community', type)
      $window.location = "#{type}/oauth"

    $scope.cancel = ->
      $scope.communityForm = null

    $scope.identity = (type) ->
      switch (type or $scope.communityForm)
        when 'facebook' then Session.user().facebookIdentity()
        when 'slack'    then Session.user().slackIdentity()

    # $scope.fetchFacebookGroups = ->
    #   Records.identities.perform(Session.user().facebookIdentityId, 'admin_groups')
    # LoadingService.applyLoadingFunction $scope, 'fetchFacebookGroups'
