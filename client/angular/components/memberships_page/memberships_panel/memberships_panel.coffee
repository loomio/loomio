Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
FlashService   = require 'shared/services/flash_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'
I18n           = require 'shared/services/i18n.coffee'

angular.module('loomioApp').directive 'membershipsPanel', ->
  scope: {memberships: '=', group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/memberships_page/memberships_panel/memberships_panel.html'
  replace: true
  controller: ($scope) ->

    $scope.canAdministerGroup = ->
      AbilityService.canAdministerGroup($scope.group)

    $scope.canRemoveMembership = (membership) ->
      AbilityService.canRemoveMembership(membership)

    $scope.canToggleAdmin = (membership) ->
      AbilityService.canAdministerGroup($scope.group) and
      (!membership.admin or $scope.canRemoveMembership(membership))

    $scope.toggleAdmin = (membership) ->
      method = if membership.admin then 'removeAdmin' else 'makeAdmin'
      return if membership.admin and membership.user() == Session.user() and !confirm(I18n.t('memberships_page.remove_admin_from_self.question'))
      Records.memberships[method](membership).then ->
        FlashService.success "memberships_page.messages.#{_.snakeCase method}_success", name: membership.userName()

    $scope.openRemoveForm = (membership) ->
      ModalService.open 'RemoveMembershipForm', membership: -> membership

    $scope.canAddMembers = ->
      AbilityService.canAddMembers($scope.group)

    $scope.invitePeople = ->
      ModalService.open 'InvitationModal', group: => $scope.group
