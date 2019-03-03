AppConfig         = require 'shared/services/app_config'

angular.module('loomioApp').directive 'currentPlanButton', ->
  scope: {group: '='}
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.plan = $scope.group.subscriptionPlan
    $scope.show = $scope.plan == 'trial'
    $scope.upgradeUrl = AppConfig.baseUrl+'upgrade'
  ]
  template: '
    <span>
      <md-button ng-if="show" href="{{upgradeUrl}}" target="_blank" class="lmo-flex__horizontal-center">
      <i class="mdi mdi-star mdi-24px premium-feature__star" aria-hidden="true"></i>
      <span translate="current_plan_button.upgrade"></span>
      <md-tooltip><span translate="current_plan_button.tooltip"></span></md-tooltip>
      </md-button>
    </span>'
