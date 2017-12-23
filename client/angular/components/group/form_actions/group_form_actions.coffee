Records = require 'shared/services/records.coffee'

{ scrollTo }           = require 'angular/helpers/window.coffee'
{ submitForm }         = require 'angular/helpers/form.coffee'
{ groupPrivacyChange } = require 'angular/helpers/helptext.coffee'

angular.module('loomioApp').directive 'groupFormActions', ($translate, KeyEventService) ->
  scope: {group: '='}
  replace: true
  templateUrl: 'generated/components/group/form_actions/group_form_actions.html'
  controller: ($scope) ->
    actionName = if $scope.group.isNew() then 'created' else 'updated'

    $scope.submit = submitForm $scope, $scope.group,
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
      confirmFn: (model)          -> $translate.instant groupPrivacyChange(model)
      flashSuccess:               -> "group_form.messages.group_#{actionName}"
      successCallback: (response) ->
        group = Records.groups.find(response.groups[0].key)
        $scope.$emit 'nextStep', group

    $scope.expandForm = ->
      $scope.group.expanded = true
      scrollTo '.group-form__permissions', container: '.group-modal md-dialog-content'

    KeyEventService.submitOnEnter $scope
