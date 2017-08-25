angular.module('loomioApp').directive 'installSlackForm', (FormService, Session, Records, LoadingService, LmoUrlService)->
  scope: {group: '='}
  templateUrl: 'generated/components/install_slack/form/install_slack_form.html'
  controller: ($scope) ->
    $scope.currentStep = if $scope.group then 'invite' else 'install'

    $scope.$on 'installComplete', (event, group) ->
      $scope.group = group
      $scope.currentStep = 'invite'
      $scope.isDisabled = false

    $scope.$on 'inviteComplete',  ->
      $scope.currentStep = 'decide'
      $scope.isDisabled = false

    $scope.$on 'decideComplete', -> $scope.$emit('$close')

    $scope.progress = ->
      switch $scope.currentStep
        when 'install' then 0
        when 'invite'  then 50
        when 'decide'  then 100

    LoadingService.listenForLoading $scope
