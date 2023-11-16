<script lang="js">
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';
import FlashService   from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';
import { snakeCase } from 'lodash-es';
import UserNameModal from  '@/components/group/user_name_modal';

export default
{
  components: { UserNameModal },

  props: {
    membership: Object
  },

  methods: {
    canPerformAction() {
      return this.canSetTitle()         ||
            this.canSetName()          ||
            this.canRemoveMembership() ||
            this.canResendMembership() ||
            this.canToggleAdmin();
    },

    canSetName() {
      return AbilityService.canAdminister(this.membership.group()) &&
      (!this.membership.user().name || !this.membership.user().emailVerified);
    },

    canSetTitle() {
      return AbilityService.canSetMembershipTitle(this.membership);
    },

    setName() {
      EventBus.$emit('openModal', {
          component: 'UserNameModal',
          props: {
            user: this.membership.user().clone()
          }
      });
    },

    setTitle() {
      EventBus.$emit('openModal', {
        component: 'MembershipModal',
        props: {
          membership: this.membership.clone()
        }
      });
    },

    canResendMembership() {
      return AbilityService.canResendMembership(this.membership);
    },

    resendMembership() {
      return this.membership.resend().then(() => FlashService.success("membership_dropdown.invitation_resent"));
    },

    canRemoveMembership() {
      return AbilityService.canRemoveMembership(this.membership);
    },

    removeMembership() {
      const namespace = this.membership.acceptedAt ? 'membership' : 'invitation';

      const messages = [];
      messages.push(this.$t(`membership_remove_modal.${namespace}.message`, { name: this.membership.user().name }));

      if (this.membership.group().parentId) {
        messages.push(this.$t("membership_remove_modal.membership.impact_for_subgroup"));
      } else {
        messages.push(this.$t("membership_remove_modal.membership.impact_for_group"));
      }

      EventBus.$emit('openModal', {
        component: 'ConfirmModal',
        props: {
          confirm: {
            membership: this.membership.clone(),
            text: {
              title:    `membership_remove_modal.${namespace}.title`,
              raw_helptext: messages.join('<br>'),
              flash:    `membership_remove_modal.${namespace}.flash`,
              submit:   `membership_remove_modal.${namespace}.submit`
            },
            submit:     this.membership.destroy,
            redirect:   ((this.membership.user() === Session.user() ? 'dashboard' : undefined))
          }
        }
      });
    },

    canToggleAdmin() {
      return ((this.membership.group().adminMembershipsCount === 0) && (this.membership.user() === Session.user())) ||
      (AbilityService.canAdminister(this.membership.group()) && (!this.membership.admin || this.canRemoveMembership(this.membership))) ||
      (this.membership.userIs(Session.user()) && this.membership.group().parentOrSelf().adminsInclude(Session.user()));
    },


    toggleAdmin(membership) {
      const method = this.membership.admin ? 'removeAdmin' : 'makeAdmin';
      if (this.membership.admin && (this.membership.user() === Session.user()) && !confirm(this.$t('memberships_page.remove_admin_from_self.question'))) { return; }
      Records.memberships[method](this.membership).then(() => {
        FlashService.success(`memberships_page.messages.${snakeCase(method)}_success`, {name: (this.membership.userName() || this.membership.userEmail)});
      });
    }
  }
};
</script>

<template lang="pug">
.membership-dropdown.lmo-no-print(v-if='canPerformAction()')
  v-menu.lmo-dropdown-menu(offset-y)
    template(v-slot:activator="{on, attrs}")
      v-btn.membership-dropdown__button(icon v-on="on" v-bind="attrs")
        //- span(v-t="'membership_dropdown.membership_options'")
        v-icon mdi-dots-vertical
    v-list.group-actions-dropdown__menu-content
      v-list-item.membership-dropdown__set-title(v-if='canSetName()' @click='setName()')
        v-list-item-title(v-t="'membership_dropdown.set_name_and_username'")
      v-list-item.membership-dropdown__set-title(v-if='canSetTitle()' @click='setTitle()')
        v-list-item-title(v-t="'membership_dropdown.set_title'")
      v-list-item.membership-dropdown__resend(v-if='canResendMembership()' @click='resendMembership()', :disabled='membership.resent')
        v-list-item-title(v-t="'membership_dropdown.resend'", v-if='!membership.resent')
        v-list-item-title(v-t="'membership_dropdown.invitation_resent'", v-if='membership.resent')
      v-list-item.membership-dropdown__toggle-admin(v-if='canToggleAdmin()' @click='toggleAdmin()')
        v-list-item-title(v-t="'membership_dropdown.make_coordinator'", v-if='!membership.admin')
        v-list-item-title(v-t="'membership_dropdown.demote_coordinator'", v-if='membership.admin')
      v-list-item.membership-dropdown__remove(v-if='canRemoveMembership()' @click='removeMembership()')
        v-list-item-title(v-if='membership.acceptedAt' v-t="'membership_dropdown.remove_from.group'")
        //- v-list-item-title(v-if='membership.acceptedAt')
        //-   span "remove membership"
        v-list-item-title(v-t="'membership_dropdown.cancel_invitation'", v-if='!membership.acceptedAt')
</template>
