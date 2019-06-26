<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import FlashService   from '@/shared/services/flash'
import ModalService   from '@/shared/services/modal_service'
import ConfirmModalMixin from '@/mixins/confirm_modal'
import MembershipModalMixin from '@/mixins/membership_modal'
import { snakeCase } from 'lodash'

export default
  mixins: [ConfirmModalMixin, MembershipModalMixin]
  props:
    membership: Object
  methods:
    canPerformAction: ->
      @canSetTitle()         or
      @canRemoveMembership() or
      @canResendMembership() or
      @canToggleAdmin()

    canSetTitle: ->
      AbilityService.canSetMembershipTitle(@membership)

    setTitle: ->
      @openMembershipModal(@membership)

    canResendMembership: ->
      AbilityService.canResendMembership(@membership)

    resendMembership: ->
      FlashService.loading()
      @membership.resend().then ->
        FlashService.success "membership_dropdown.invitation_resent"

    canRemoveMembership: ->
      AbilityService.canRemoveMembership(@membership)

    removeMembership: ->
      namespace = if @membership.acceptedAt then 'membership' else 'invitation'
      @openConfirmModal(
        scope:
          namespace: namespace
          user: @membership.user()
          group: @membership.group()
          membership: @membership
        text:
          title:    "membership_remove_modal.#{namespace}.title"
          fragment: "membership_remove_modal"
          flash:    "membership_remove_modal.#{namespace}.flash"
          submit:   "membership_remove_modal.#{namespace}.submit"
        submit:     @membership.destroy
        redirect:   ('dashboard' if @membership.user() == Session.user())
      )

    canToggleAdmin: ->
      (@membership.group().adminMembershipsCount == 0 and @membership.user() == Session.user()) or
      (AbilityService.canAdministerGroup(@membership.group()) and (!@membership.admin or @canRemoveMembership(@membership))) or
      (@membership.user() == Session.user() && Session.user().isAdminOf(@membership.group().parent()))


    toggleAdmin: (membership) ->
      method = if @membership.admin then 'removeAdmin' else 'makeAdmin'
      return if @membership.admin and @membership.user() == Session.user() and !confirm(@$t('memberships_page.remove_admin_from_self.question'))
      Records.memberships[method](@membership).then =>
        FlashService.success "memberships_page.messages.#{snakeCase method}_success", name: (@membership.userName() || @membership.userEmail())
</script>
<template lang="pug">
.membership-dropdown.lmo-no-print(v-if='canPerformAction()')
  v-menu.lmo-dropdown-menu(offset-y)
    template(v-slot:activator="{on}")
      v-btn.membership-dropdown__button(icon v-on="on")
        //- span(v-t="'membership_dropdown.membership_options'")
        v-icon mdi-dots-vertical
    v-list.group-actions-dropdown__menu-content
      v-list-item.membership-dropdown__set-title(v-if='canSetTitle()' @click='setTitle()')
        v-list-item-title(v-t="'membership_dropdown.set_title'")
      v-list-item.membership-dropdown__resend(v-if='canResendMembership()' @click='resendMembership()', :disabled='membership.resent')
        v-list-item-title(v-t="'membership_dropdown.resend'", v-if='!membership.resent')
        v-list-item-title(v-t="'membership_dropdown.invitation_resent'", v-if='membership.resent')
      v-list-item.membership-dropdown__toggle-admin(v-if='canToggleAdmin()' @click='toggleAdmin()')
        v-list-item-title(v-t="'membership_dropdown.make_coordinator'", v-if='!membership.admin')
        v-list-item-title(v-t="'membership_dropdown.demote_coordinator'", v-if='membership.admin')
      v-list-item.membership-dropdown__remove(v-if='canRemoveMembership()' @click='removeMembership()')
        v-list-item-title(v-if='membership.acceptedAt' v-t="{ path: 'membership_dropdown.remove_from.' + membership.group().targetModel().constructor.singular, args: {pollType: membership.group().targetModel().isA('poll') && membership.group().targetModel().translatedPollType()} }")
        //- v-list-item-title(v-if='membership.acceptedAt')
        //-   span "remove membership"
        v-list-item-title(v-t="'membership_dropdown.cancel_invitation'", v-if='!membership.acceptedAt')
</template>
