AppConfig      = require 'shared/services/app_config'
AbilityService = require 'shared/services/ability_service'
I18n           = require 'shared/services/i18n'
Records        = require 'shared/services/records'

{ groupPrivacy, groupPrivacyStatement } = require 'shared/helpers/helptext'

angular.module('loomioApp').directive 'groupForm', ->
  scope: {group: '=', modal: '=?'}
  templateUrl: 'generated/components/group/form/group_form.html'
  controller: ['$scope', ($scope) ->

    $scope.suggestHandle = ->
      # if group is new, suggest handle whenever name changes
      # if group is old, suggest handle only if handle is empty
      if $scope.group.isNew() or _.isEmpty($scope.group.handle)
        parentHandle = if $scope.group.parent()
          $scope.group.parent().handle
        else
          null
        Records.groups.getHandle(name: $scope.group.name, parentHandle: parentHandle).then (data) ->
          $scope.group.handle = data.handle

    $scope.suggestHandle()

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
      I18n.t groupPrivacyStatement($scope.group),
        parent: $scope.group.parentName()

    $scope.privacyStringFor = (privacy) ->
      I18n.t groupPrivacy($scope.group, privacy),
        parent: $scope.group.parentName()

    $scope.showGroupFeatures = ->
      AbilityService.isSiteAdmin() and _.some($scope.featureNames)

    $scope.featureNames = AppConfig.features.group
  ]
