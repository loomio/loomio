AppConfig      = require 'shared/services/app_config.coffee'
Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

angular.module('loomioApp').directive 'groupActionsDropdown', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_actions_dropdown/group_actions_dropdown.html'
  replace: true
  controller: ['$scope', ($scope) ->

    $scope.canAdministerGroup = ->
      AbilityService.canAdministerGroup($scope.group)

    $scope.canEditGroup = =>
      AbilityService.canEditGroup($scope.group)

    $scope.canAddSubgroup = ->
      AbilityService.canCreateSubgroups($scope.group)

    $scope.canArchiveGroup = =>
      AbilityService.canArchiveGroup($scope.group)

    $scope.canLeaveGroup = =>
      AbilityService.canRemoveMembership($scope.group.membershipFor(Session.user()))

    $scope.canChangeVolume = ->
      AbilityService.canChangeGroupVolume($scope.group)

    $scope.openChangeVolumeForm = ->
      ModalService.open 'ChangeVolumeForm', model: -> $scope.group.membershipFor(Session.user())

    $scope.editGroup = ->
      ModalService.open 'GroupModal', group: -> $scope.group

    $scope.addSubgroup = ->
      ModalService.open 'GroupModal', group: -> Records.groups.build(parentId: $scope.group.id)

    $scope.leaveGroup = ->
      ModalService.open 'ConfirmModal', confirm: ->
        submit:  Session.user().membershipFor($scope.group).destroy
        text:
          title:    'leave_group_form.title'
          helptext: 'leave_group_form.question'
          confirm:  'leave_group_form.submit'
          flash:    'group_page.messages.leave_group_success'
        redirect: 'dashboard'

    $scope.archiveGroup = ->
      ModalService.open 'ConfirmModal', confirm: ->
        submit:     $scope.group.archive
        text:
          title:    'archive_group_form.title'
          helptext: 'archive_group_form.question'
          flash:    'group_page.messages.archive_group_success'
        redirect:   'dashboard'

    return
  ]
