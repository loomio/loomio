angular.module('loomioApp').factory 'SignedOutModal', ->
  templateUrl: 'generated/components/signed_out_modal/signed_out_modal.html'
  controller: ($scope, preventClose, Session) ->
    $scope.preventClose = preventClose
    $scope.submit = Session.logout
