angular.module('loomioApp').factory 'DonationModal', ->
  templateUrl: 'generated/components/group_page/trial_card/donation_modal/donation_modal.html'
  size: 'confirm-gift-plan-modal'
  controller: ($scope, group, $window, AppConfig, CurrentUser) ->
    $scope.group = group

    $scope.makeDonation = ->
      $window.open "#{AppConfig.chargify.donation_url}?#{encodedChargifyParams()}", '_blank'
      true

    encodedChargifyParams = ->
      params =
        first_name: CurrentUser.firstName()
        last_name: CurrentUser.lastName()
        email: CurrentUser.email
        organization: $scope.group.name
        reference: $scope.group.key

      _.map(_.keys(params), (key) ->
        encodeURIComponent(key) + "=" + encodeURIComponent(params[key])
      ).join('&')