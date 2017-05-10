angular.module('loomioApp').factory 'AuthModal', ->
  templateUrl: 'generated/components/auth/modal/auth_modal.html'
  controller: ($scope, preventClose) ->
    $scope.preventClose = preventClose
    $scope.$on 'signedIn', $scope.$close
