angular.module('loomioApp').factory 'DiscussionForm', ->
  templateUrl: 'generated/components/discussion_form/discussion_form.html'
  controller: ($scope, $controller, $location, discussion, CurrentUser, Records, AbilityService, FormService, KeyEventService, PrivacyString) ->
    $scope.discussion = discussion.clone()

    if $scope.discussion.isNew()
      $scope.showGroupSelect = true

    actionName = if $scope.discussion.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.discussion,
      flashSuccess: "discussion_form.messages.#{actionName}"
      allowDrafts: true
      successCallback: (response) =>
        $location.path "/d/#{response.discussions[0].key}" if actionName == 'created'

    $scope.availableGroups = ->
      _.filter CurrentUser.groups(), (group) ->
        AbilityService.canStartThread(group)

    $scope.privacyPrivateDescription = ->
      PrivacyString.discussion($scope.discussion, true)

    $scope.showPrivacyForm = ->
      return unless $scope.discussion.group()
      $scope.discussion.group().discussionPrivacyOptions == 'public_or_private'

    KeyEventService.submitOnEnter $scope
