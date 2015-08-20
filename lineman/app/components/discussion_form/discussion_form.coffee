angular.module('loomioApp').factory 'DiscussionForm', ->
  templateUrl: 'generated/components/discussion_form/discussion_form.html'
  controller: ($scope, $controller, $location, discussion, CurrentUser, Records, FormService, KeyEventService) ->
    $scope.discussion = discussion.clone()

    $scope.$on 'modal.closing', (event) ->
      FormService.confirmDiscardChanges(event, $scope.discussion)

    actionName = if $scope.discussion.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.discussion,
      flashSuccess: "discussion_form.messages.#{actionName}"
      successCallback: (response) =>
        $location.path "/d/#{response.discussions[0].key}" if actionName == 'created'

    $scope.availableGroups = ->
      groups = _.filter CurrentUser.groups(), (group) ->
        group.membersCanStartDiscussions or group.admins().include? CurrentUser
      _.sortBy groups, (g) -> g.fullName()

    $scope.showPrivacyForm = ->
      $scope.discussion.group()? and $scope.discussion.group().discussionPrivacyOptions == 'public_or_private'

    KeyEventService.submitOnEnter $scope
