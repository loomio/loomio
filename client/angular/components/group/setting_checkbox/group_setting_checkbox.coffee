angular.module('loomioApp').directive 'groupSettingCheckbox', ->
  scope: {group: '=', setting: '@', translateValues: '=?'}
  template: require('./group_setting_checkbox.haml')
  controller: ['$scope', ($scope) ->
    $scope.translateKey = ->
      "group_form.#{_.snakeCase($scope.setting)}"
  ]
