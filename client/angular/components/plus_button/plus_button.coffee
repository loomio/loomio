Records = require 'shared/services/records'

angular.module('loomioApp').directive 'plusButton', ->
  scope: {click: '=', message: '@'}
  restrict: 'E'
  template: require('./plus_button.haml')
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.plusUser = Records.users.build(avatarKind: 'mdi-plus')
  ]
