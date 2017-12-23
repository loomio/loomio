AppConfig      = require 'shared/services/app_config.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

angular.module('loomioApp').directive 'groupForm', (PrivacyString) ->
  scope: {group: '=', modal: '=?'}
  templateUrl: 'generated/components/group/form/group_form.html'
  controller: ($scope) ->

    $scope.titleLabel = ->
      if $scope.group.isParent()
        "group_form.group_name"
      else
        "group_form.subgroup_name"

    $scope.privacyOptions = ->
      if $scope.group.isSubgroup() && $scope.group.parent().groupPrivacy == 'secret'
        ['closed', 'secret']
      else
        ['open', 'closed', 'secret']

    $scope.privacyStatement = ->
      PrivacyString.groupPrivacyStatement($scope.group)

    $scope.privacyStringFor = (privacy) ->
      PrivacyString.group($scope.group, privacy)

    $scope.showGroupFeatures = ->
      AbilityService.isSiteAdmin() and _.any($scope.featureNames)

    $scope.featureNames = AppConfig.features.group
