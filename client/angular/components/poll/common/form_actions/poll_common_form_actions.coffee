{ submitOnEnter } = require 'angular/helpers/keyboard.coffee'
{ submitPoll }    = require 'angular/helpers/form.coffee'

angular.module('loomioApp').directive 'pollCommonFormActions', ($rootScope) ->
  scope: {poll: '='}
  replace: true
  templateUrl: 'generated/components/poll/common/form_actions/poll_common_form_actions.html'
  controller: ($scope) ->
    $scope.submit = submitPoll($scope, $scope.poll, broadcaster: $rootScope)
    submitOnEnter $scope
