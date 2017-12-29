angular.module('loomioApp').directive 'groupSettingCheckbox', ->
  scope: {group: '=', setting: '@', translateValues: '=?'}
  templateUrl: 'generated/components/group/setting_checkbox/group_setting_checkbox.html'
  controller: ['$scope', ($scope) ->
    $scope.translateKey = ->
      "group_form.#{_.snakeCase($scope.setting)}"
  ]
