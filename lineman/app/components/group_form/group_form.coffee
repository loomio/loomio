angular.module('loomioApp').factory 'GroupForm', ->
  templateUrl: 'generated/components/group_form/group_form.html'
  controller: ($scope, $rootScope, $location, group, FormService, Records, $translate, PrivacyString) ->
    $scope.group = group.clone()

    $scope.$on 'modal.closing', (event) ->
      FormService.confirmDiscardChanges(event, $scope.group)

    $scope.i18n = do ->
      h = {}
      if $scope.group.isParent()
        h.group_name = 'group_form.group_name'
        if $scope.group.isNew()
          h.heading = 'group_form.start_group_heading'
          h.submit = 'group_form.submit_start_group'
        else
          h.heading = 'group_form.edit_group_heading'
          h.submit = 'common.action.update_settings'
      else
        h.group_name = 'group_form.subgroup_name'
        if $scope.group.isNew()
          h.heading = 'group_form.start_subgroup_heading'
          h.submit = 'group_form.submit_start_subgroup'
        else
          h.heading = 'group_form.edit_subgroup_heading'
          h.submit = 'common.action.update_settings'
      h



    successMessage = ->
      if $scope.group.isNew()
        'group_form.messages.group_created'
      else
        'group_form.messages.group_updated'

    submitForm = FormService.submit $scope, $scope.group,
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
