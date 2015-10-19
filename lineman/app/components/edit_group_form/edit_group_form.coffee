angular.module('loomioApp').factory 'EditGroupForm', ->
  templateUrl: 'generated/components/edit_group_form/edit_group_form.html'
  controller: ($scope, $rootScope, group, FormService, Records, KeyEventService) ->
    $scope.group = group.clone()

    $scope.submit = FormService.submit $scope, $scope.group,
      flashSuccess: 'edit_group_form.messages.success'

    $scope.validVisibilityOption = (value) =>
      switch value
        when 'public'         then !$scope.group.parentIsHidden()
        when 'parent_members' then $scope.group.parentId
        when 'members'        then true

    $scope.validMembershipOption = (value) =>
      switch value
        when 'request'    then $scope.group.visibleTo != 'members'
        when 'approval'   then $scope.group.visibleTo != 'members'
        when 'invitation' then true

    $scope.validDiscussionOption = (value) =>
      switch value
        when 'public_only'       then $scope.group.visibleTo != 'members'
        when 'public_or_private' then $scope.group.visibleTo != 'members'
        when 'private_only'      then true

    $scope.firstOption = (isVisible, options) =>
      =>
        for option in options
          return option if isVisible(option)
        return

    $scope.firstVisibilityOption = $scope.firstOption($scope.validVisibilityOption, ['public', 'parent_members', 'members'])
    $scope.firstMembershipOption = $scope.firstOption($scope.validMembershipOption, ['request', 'approval', 'invitation'])
    $scope.firstDiscussionOption = $scope.firstOption($scope.validDiscussionOption, ['public_only', 'public_or_private', 'private_only'])

    $scope.updateOptions = =>
      if !$scope.validVisibilityOption($scope.group.visibleTo)
        $scope.group.visibleTo = $scope.firstVisibilityOption()
      if !$scope.validMembershipOption($scope.group.membershipGrantedUpon)
        $scope.group.membershipGrantedUpon = $scope.firstMembershipOption()
      if !$scope.validDiscussionOption($scope.group.discussionPrivacyOptions)
        $scope.group.discussionPrivacyOptions = $scope.firstDiscussionOption($scope.group.discussionPrivacyOptions)

    $scope.privacyTranslation = (value) =>
      if $scope.group.parentId then "#{value}_subgroup" else value

    KeyEventService.submitOnEnter $scope

    return
