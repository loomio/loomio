Session        = require 'shared/services/session'
AbilityService = require 'shared/services/ability_service'
I18n           = require 'shared/services/i18n'

{ discussionPrivacy } = require 'shared/helpers/helptext'

angular.module('loomioApp').directive 'discussionForm', ->
  scope: {discussion: '='}
  templateUrl: 'generated/components/discussion/form/discussion_form.html'
  controller: ['$scope', ($scope) ->
    if $scope.discussion.isNew()
      $scope.showGroupSelect = true

    $scope.availableGroups = ->
      _.filter Session.user().formalGroups(), (group) ->
        AbilityService.canStartThread(group)

    $scope.privacyPrivateDescription = ->
      I18n.t discussionPrivacy($scope.discussion, true),
        group:  $scope.discussion.group().name,
        parent: $scope.discussion.group().parentName()

    $scope.updatePrivacy = ->
      $scope.discussion.private = $scope.discussion.privateDefaultValue()

    $scope.showPrivacyForm = ->
      return true unless $scope.discussion.group()
      $scope.discussion.group().discussionPrivacyOptions == 'public_or_private'
  ]
