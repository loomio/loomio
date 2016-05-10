angular.module('loomioApp').directive 'giftCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/gift_card/gift_card.html'
  replace: true
  controller: ($scope, $window, AppConfig, Session, ChargifyService) ->

    $scope.show = ->
      Session.user().isMemberOf($scope.group) and
      $scope.group.subscriptionKind == 'gift' and
      AppConfig.chargify?

    $scope.makeDonation = ->
      $window.open "#{AppConfig.chargify.donation_url}?#{ChargifyService.encodedParams($scope.group)}", '_blank'
      true
