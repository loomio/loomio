{ submitOnEnter } = require 'shared/helpers/keyboard'
{ submitPoll }    = require 'shared/helpers/form'

angular.module('loomioApp').directive 'pollCommonFormActions', ['$rootScope', ($rootScope) ->
  scope: {poll: '='}
  replace: true
  templateUrl: 'generated/components/poll/common/form_actions/poll_common_form_actions.html'
  controller: ['$scope', ($scope) ->
    $scope.submit = submitPoll($scope, $scope.poll, broadcaster: $rootScope)
    submitOnEnter $scope
  ]
]
