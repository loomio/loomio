angular.module('loomioApp').factory 'DiscussionForm', (Records) ->
  templateUrl: 'generated/components/discussion_form/discussion_form.html'
  controller: ($scope, $controller, $location, discussion, CurrentUser, Records, FormService) ->

    $scope.$on 'modal.closing', (event) ->
      FormService.confirmDiscardChanges(event, $scope.discussion)

    $scope.discussion = discussion.clone()

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
      if $scope.discussion.groupId
        $scope.discussion.group().privacy == 'public_or_private'

