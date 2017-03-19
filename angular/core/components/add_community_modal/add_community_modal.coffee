angular.module('loomioApp').factory 'AddCommunityModal', ->
  templateUrl: 'generated/components/add_community_modal/add_community_modal.html'
  controller: ($scope, poll) ->
    $scope.poll = poll
