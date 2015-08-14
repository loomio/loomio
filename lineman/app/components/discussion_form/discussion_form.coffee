angular.module('loomioApp').factory 'DiscussionForm', (Records) ->
  templateUrl: 'generated/components/discussion_form/discussion_form.html'
  controller: ($scope, $controller, $location, discussion, CurrentUser, Records, FormService, $filter) ->

    $scope.$on 'modal.closing', (event) ->
      if $scope.discussion.isModified() && !confirm($filter('translate')('common.confirm_discard_changes'))
        console.log 'preventing close'
        return event.preventDefault()

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


    $scope.getCurrentPrivacy = ->
      $scope.discussion.group().discussionPrivacyOptions if $scope.discussion.group()

    $scope.setCurrentPrivacy = ->
      if $scope.discussion.isNew()
        $scope.discussion.private = $scope.getCurrentPrivacy() == 'private_only'

    $scope.setCurrentPrivacy()

    $scope.showPrivacyForm = ->
      $scope.getCurrentPrivacy() == 'public_or_private'

