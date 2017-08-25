angular.module('loomioApp').directive 'groupForm', ->
  scope: {group: '='}
  templateUrl: 'generated/components/group/form/group_form.html'
  controller: ($scope, $q, $window, $location, KeyEventService, LmoUrlService, FormService, Records, PrivacyString) ->

    $scope.titleLabel = ->
      if $scope.group.isParent()
        "group_form.group_name"
      else
        "group_form.subgroup_name"

    $scope.privacyOptions = ->
      if $scope.group.isSubgroup() && $scope.group.parent().groupPrivacy == 'secret'
        ['closed', 'secret']
      else
        ['open', 'closed', 'secret']

    actionName = if $scope.group.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.group,
      drafts: true
      skipClose: true
      prepareFn: ->
        allowPublic = $scope.group.allowPublicThreads
        $scope.group.discussionPrivacyOptions = switch $scope.group.groupPrivacy
          when 'open'   then 'public_only'
          when 'closed' then (if allowPublic then 'public_or_private' else 'private_only')
          when 'secret' then 'private_only'

        $scope.group.parentMembersCanSeeDiscussions = switch $scope.group.groupPrivacy
          when 'open'   then true
          when 'closed' then $scope.group.parentMembersCanSeeDiscussions
          when 'secret' then false
      confirmFn: (model) -> PrivacyString.confirmGroupPrivacyChange(model)
      flashSuccess: -> "group_form.messages.group_#{actionName}"
      successCallback: (response) ->
        group = Records.groups.find(response.groups[0].key)
        $scope.$emit 'createComplete', group
        $location.path LmoUrlService.group(group)

    $scope.expandForm = -> $scope.expanded = true

    $scope.privacyStatement = ->
      PrivacyString.groupPrivacyStatement($scope.group)

    $scope.privacyStringFor = (privacy) ->
      PrivacyString.group($scope.group, privacy)

    KeyEventService.submitOnEnter $scope
