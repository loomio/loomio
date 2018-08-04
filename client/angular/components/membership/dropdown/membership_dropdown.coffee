Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
AbilityService = require 'shared/services/ability_service'
FlashService   = require 'shared/services/flash_service'
ModalService   = require 'shared/services/modal_service'
I18n           = require 'shared/services/i18n'

angular.module('loomioApp').directive 'membershipDropdown', ->
  scope: {membership: '='}
  restrict: 'E'
  templateUrl: 'generated/components/membership/dropdown/membership_dropdown.html'
  controller: ['$scope', ($scope) ->
    $scope.canPerformAction = ->
      $scope.canSetTitle()         or
      $scope.canRemoveMembership() or
      $scope.canResendMembership() or
      $scope.canToggleAdmin()

    $scope.canSetTitle = ->
      AbilityService.canSetMembershipTitle($scope.membership)

    $scope.setTitle = ->
      ModalService.open 'MembershipModal', membership: -> $scope.membership

    $scope.canResendMembership = ->
      AbilityService.canResendMembership($scope.membership)

    $scope.resendMembership = ->
      FlashService.loading()
      $scope.membership.resend().then ->
        FlashService.success "membership_dropdown.invitation_resent"

    $scope.canRemoveMembership = ->
      AbilityService.canRemoveMembership($scope.membership)

    $scope.removeMembership = ->
      namespace = if $scope.membership.acceptedAt then 'membership' else 'invitation'
      ModalService.open 'ConfirmModal', confirm: ->
        scope:
          namespace: namespace
          user: $scope.membership.user()
          group: $scope.membership.group()
          membership: $scope.membership
        text:
          title:    "membership_remove_modal.#{namespace}.title"
          fragment: "membership_remove_modal"
          flash:    "membership_remove_modal.#{namespace}.flash"
          submit:   "membership_remove_modal.#{namespace}.submit"
        submit:     $scope.membership.destroy
        redirect:   ('dashboard' if $scope.membership.user() == Session.user())

    $scope.canToggleAdmin = ->
      ($scope.membership.group().adminMembershipsCount == 0 and $scope.membership.user() == Session.user()) or
      AbilityService.canAdministerGroup($scope.membership.group()) and
      (!$scope.membership.admin or $scope.canRemoveMembership($scope.membership))

    $scope.toggleAdmin = (membership) ->
      method = if $scope.membership.admin then 'removeAdmin' else 'makeAdmin'
      return if $scope.membership.admin and $scope.membership.user() == Session.user() and !confirm(I18n.t('memberships_page.remove_admin_from_self.question'))
      Records.memberships[method]($scope.membership).then ->
        FlashService.success "memberships_page.messages.#{_.snakeCase method}_success", name: ($scope.membership.userName() || $scope.membership.userEmail())
  ]
