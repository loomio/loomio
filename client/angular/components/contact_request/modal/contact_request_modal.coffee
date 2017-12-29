angular.module('loomioApp').factory 'ContactRequestModal', ->
  templateUrl: 'generated/components/contact_request/modal/contact_request_modal.html'
  controller: ['$scope', 'user', ($scope, user) ->
    $scope.user = user
    $scope.$on '$close', $scope.$close
  ]
