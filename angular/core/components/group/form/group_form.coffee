angular.module('loomioApp').directive 'groupForm', ->
  scope: {group: '='}
  templateUrl: 'generated/components/group/form/group_form.html'
  controller: ($scope, $q, $window, $location, KeyEventService, LmoUrlService, FormService, Records, PrivacyString) ->

    submitForm = FormService.submit $scope, $scope.group,
      drafts: true
      skipClose: true
      flashSuccess: ->
        if $scope.group.isNew()
          'group_form.messages.group_created'
        else
          'group_form.messages.group_updated'
      successCallback: (response) ->
        group = Records.groups.find(response.groups[0].key)
        $scope.$emit 'createComplete', group
        $location.path LmoUrlService.group(group)

    $scope.submit = FormService.submit $scope, $scope.group,
      drafts: true
      skipClose: true
      submitFn: (model) ->
        confirmation = PrivacyString.confirmGroupPrivacyChange(model)
        if !confirmation || $window.confirm(message)
          model.save
        else
          $q.defer
      flashSuccess: ->
        if $scope.group.isNew()
          'group_form.messages.group_created'
        else
          'group_form.messages.group_updated'
      successCallback: (response) ->
        group = Records.groups.find(response.groups[0].key)
        $scope.$emit 'createComplete', group
        $location.path LmoUrlService.group(group)

    $scope.expandForm = -> $scope.expanded = true

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
