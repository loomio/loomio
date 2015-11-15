angular.module('loomioApp').directive 'giftCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/gift_card/gift_card.html'
  replace: true
  controller: ($scope, $window, AppConfig, CurrentUser) ->

    $scope.show = ->
      CurrentUser.isMemberOf($scope.group) and
      $scope.group.subscriptionKind == 'gift' and
      AppConfig.chargify?

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
