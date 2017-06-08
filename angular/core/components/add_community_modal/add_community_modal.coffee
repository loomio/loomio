angular.module('loomioApp').factory 'AddCommunityModal', ->
  templateUrl: 'generated/components/add_community_modal/add_community_modal.html'
  controller: ($scope, community) ->
    $scope.community = community
