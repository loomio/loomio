AppConfig = require 'shared/services/app_config'
angular.module('loomioApp').directive 'trialBanner', ->
  scope: {group: '='}
  templateUrl: 'generated/components/trial_banner/trial_banner.html'
  replace: true
  controller: ['$scope', ($scope) ->
    console.log 'hi'
    $scope.upgradeUrl = AppConfig.baseUrl+'upgrade'
    $scope.isTrialing = $scope.group.subscriptionState == 'trialing'
    $scope.isExpired = $scope.isTrialing && !$scope.group.subscriptionActive
    $scope.daysRemaining = $scope.group.subscriptionExpiresAt.diff(moment(), 'days') + 1
  ]
