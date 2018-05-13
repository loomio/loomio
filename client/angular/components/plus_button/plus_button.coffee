Records = require 'shared/services/records'

angular.module('loomioApp').directive 'plusButton', ->
  scope: {click: '=', message: '@'}
  restrict: 'E'
  templateUrl: 'generated/components/plus_button/plus_button.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.plusUser = Records.users.build(avatarKind: 'mdi-plus')
  ]
