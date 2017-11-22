angular.module('loomioApp').directive 'discussionForm', ->
  scope: {discussion: '='}
  templateUrl: 'generated/components/discussion/form/discussion_form.html'
  controller: ($scope, $location, Session, AbilityService, PrivacyString) ->
    $scope.showGroupSelect = $scope.discussion.isNew()

    $scope.availableGroups = ->
      _.filter Session.user().groups(), (group) ->
        AbilityService.canStartThread(group)

    # NB; this overrides the restoreDraft() function applied in draft_service
    $scope.restoreDraft = ->
      return unless $scope.discussion.group()? and $scope.discussion.isNew()
      $scope.discussion.restoreDraft()
      $scope.updatePrivacy()

    $scope.privacyPrivateDescription = ->
      PrivacyString.discussion($scope.discussion, true)

    $scope.updatePrivacy = ->
      $scope.discussion.private = $scope.discussion.privateDefaultValue()

    $scope.showPrivacyForm = ->
      return unless $scope.discussion.group()
      $scope.discussion.group().discussionPrivacyOptions == 'public_or_private'
