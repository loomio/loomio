angular.module('loomioApp').factory 'GroupForm', ->
  templateUrl: 'generated/components/group_form/group_form.html'
  controller: ($scope, $rootScope, $location, group, KeyEventService, FormService, Records, $translate, PrivacyString) ->
    $scope.group = group.clone()

    $scope.i18n = do ->
      groupMessaging = {}
      if $scope.group.isParent()
        groupMessaging.group_name = 'group_form.group_name'
        if $scope.group.isNew()
          groupMessaging.heading = 'group_form.start_group_heading'
          groupMessaging.submit = 'group_form.submit_start_group'
        else
          groupMessaging.heading = 'group_form.edit_group_heading'
          groupMessaging.submit = 'common.action.update_settings'
      else
        groupMessaging.group_name = 'group_form.subgroup_name'
        if $scope.group.isNew()
          groupMessaging.heading = 'group_form.start_subgroup_heading'
          groupMessaging.submit = 'group_form.submit_start_subgroup'
        else
          groupMessaging.heading = 'group_form.edit_subgroup_heading'
          groupMessaging.submit = 'common.action.update_settings'
      groupMessaging

    successMessage = ->
      if $scope.group.isNew()
        'group_form.messages.group_created'
      else
        'group_form.messages.group_updated'

    submitForm = FormService.submit $scope, $scope.group,
      drafts: true
      flashSuccess: successMessage()
      successCallback: (response) ->
        if $scope.group.isNew()
          $location.path "/g/#{response.groups[0].key}"

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

    $scope.groupPrivacyChanged = ->
      $scope.group.parentMembersCanSeeDiscussions = !$scope.group.privacyIsSecret()
      switch $scope.group.groupPrivacy
        when 'open'   then $scope.group.discussionPrivacyOptions = 'public_only'
        when 'closed' then $scope.allowPublicThreadsClicked()
        when 'secret' then $scope.group.discussionPrivacyOptions = 'private_only'

    KeyEventService.submitOnEnter $scope
