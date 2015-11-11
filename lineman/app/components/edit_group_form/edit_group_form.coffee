angular.module('loomioApp').factory 'EditGroupForm', ->
  templateUrl: 'generated/components/edit_group_form/edit_group_form.html'
  controller: ($scope, $rootScope, group, FormService, Records, $translate, PrivacyString) ->
    $scope.group = group.clone()

    submitForm = FormService.submit $scope, $scope.group,
      flashSuccess: 'edit_group_form.messages.success'

    $scope.submit = ->
      if message = PrivacyString.confirmGroupPrivacyChange($scope.group)
        submitForm() if window.confirm(message)
      else
        submitForm()

    $scope.expandForm = ->
      $scope.expanded = true

    $scope.privacyStatement = ->
      PrivacyString.groupPrivacyStatement($scope.group)

    $scope.privacyStringFor = (state) ->
      PrivacyString.group($scope.group, state)

    $scope.buh = {}
    $scope.buh.allowPublicThreads = $scope.group.allowPublicDiscussions()

    $scope.allowPublicThreadsClicked = ->
      if $scope.buh.allowPublicThreads
        $scope.group.discussionPrivacyOptions = 'public_or_private'
      else
        $scope.group.discussionPrivacyOptions = 'private_only'
