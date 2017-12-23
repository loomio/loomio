AppConfig      = require 'shared/services/app_config.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

{ groupPrivacy, groupPrivacyStatement } = require 'angular/helpers/helptext.coffee'

angular.module('loomioApp').directive 'groupForm', ($translate) ->
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
      $translate.instant groupPrivacyStatement($scope.group),
        parent: $scope.group.parentName()

    $scope.privacyStringFor = (privacy) ->
      $translate.instant groupPrivacy($scope.group, privacy),
        parent: $scope.group.parentName()

    $scope.showGroupFeatures = ->
      AbilityService.isSiteAdmin() and _.any($scope.featureNames)

    $scope.featureNames = AppConfig.features.group
