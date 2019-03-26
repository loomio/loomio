Records  = require 'shared/services/records'
EventBus = require 'shared/services/event_bus'
I18n     = require 'shared/services/i18n'

{ scrollTo }            = require 'shared/helpers/layout'
{ submitForm }          = require 'shared/helpers/form'
{ groupPrivacyConfirm } = require 'shared/helpers/helptext'
{ submitOnEnter }       = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'groupFormActions', ->
  scope: {group: '='}
  replace: true
  templateUrl: 'generated/components/group/form_actions/group_form_actions.html'
  controller: ['$scope', ($scope) ->
    actionName = if $scope.group.isNew() then 'created' else 'updated'

    $scope.submit = submitForm $scope, $scope.group,
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
      confirmFn: (model)          -> I18n.t groupPrivacyConfirm(model)
      flashSuccess:               -> "group_form.messages.group_#{actionName}"
      successCallback: (response) ->
        group = Records.groups.find(response.groups[0].key)
        EventBus.emit $scope, 'nextStep', group

    $scope.expandForm = ->
      $scope.group.expanded = true
      scrollTo '.group-form__permissions', container: '.group-modal md-dialog-content'

    submitOnEnter $scope
  ]
