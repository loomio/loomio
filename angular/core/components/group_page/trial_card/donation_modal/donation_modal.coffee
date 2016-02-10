angular.module('loomioApp').factory 'DonationModal', ->
  templateUrl: 'generated/components/group_page/trial_card/donation_modal/donation_modal.html'
  size: 'confirm-gift-plan-modal'
  controller: ($scope, group, $window, AppConfig, ChargifyService) ->
    $scope.group = group

    $scope.makeDonation = ->
      $window.open "#{AppConfig.chargify.donation_url}?#{ChargifyService.encodedParams($scope.group)}", '_blank'
      true
