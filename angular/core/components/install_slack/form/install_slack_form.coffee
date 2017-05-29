angular.module('loomioApp').directive 'installSlackForm', (FormService, Session, Records, LmoUrlService)->
  templateUrl: 'generated/components/install_slack/form/install_slack_form.html'
  controller: ($scope) ->
    $scope.currentStep = 'install'

    $scope.$on 'installComplete', (event, group) ->
      $scope.group = group
      $scope.currentStep = 'invite'
      $scope.isDisabled = false

    $scope.$on 'inviteComplete',  ->
      $scope.currentStep = 'decide'
      $scope.isDisabled = false

    $scope.$on 'decideComplete', $scope.$close

    $scope.$on 'processing',      -> $scope.isDisabled = true
    $scope.$on 'doneProcessing',  -> $scope.isDisabled = false

    $scope.progress = ->
      switch $scope.currentStep
        when 'install' then 0
        when 'invite'  then 50
        when 'decide'  then 100
