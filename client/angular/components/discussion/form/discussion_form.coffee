Session        = require 'shared/services/session.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

{ discussionPrivacy } = require 'angular/helpers/helptext.coffee'

angular.module('loomioApp').directive 'discussionForm', ($location, $translate) ->
  scope: {discussion: '=', modal: '=?'}
  templateUrl: 'generated/components/discussion/form/discussion_form.html'
  controller: ($scope) ->
    if $scope.discussion.isNew()
      $scope.showGroupSelect = true
      $scope.discussion.makeAnnouncement = true

    $scope.availableGroups = ->
      _.filter Session.user().groups(), (group) ->
        AbilityService.canStartThread(group)

    # NB; this overrides the restoreDraft() function applied in draft_service
    $scope.restoreDraft = ->
      return unless $scope.discussion.group()? and $scope.discussion.isNew()
      $scope.discussion.restoreDraft()
      $scope.updatePrivacy()

    $scope.privacyPrivateDescription = ->
      $translate.instant discussionPrivacy($scope.discussion, true),
        group:  $scope.discussion.group().name,
        parent: $scope.discussion.group().parentName()

    $scope.updatePrivacy = ->
      $scope.discussion.private = $scope.discussion.privateDefaultValue()

    $scope.showPrivacyForm = ->
      return unless $scope.discussion.group()
      $scope.discussion.group().discussionPrivacyOptions == 'public_or_private'
