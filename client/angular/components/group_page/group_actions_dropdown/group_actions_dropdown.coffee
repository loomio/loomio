AppConfig      = require 'shared/services/app_config'
Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

angular.module('loomioApp').directive 'groupActionsDropdown', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_actions_dropdown/group_actions_dropdown.html'
  replace: true
  controller: ['$scope', ($scope) ->

    $scope.baseUrl = AppConfig.baseUrl

    $scope.canExportData = ->
      Session.user().isMemberOf($scope.group)

    $scope.openGroupExportModal = ->
      ModalService.open 'ConfirmModal', confirm: ->
        submit: $scope.group.export
        text:
          title:    'group_export_modal.title'
          helptext: 'group_export_modal.body'
          submit:   'group_export_modal.submit'
          flash:    'group_export_modal.flash'

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
