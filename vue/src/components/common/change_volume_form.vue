<script lang="js">
import Session from '@/shared/services/session';
import GroupService from '@/shared/services/group_service';
import Flash from '@/shared/services/flash';
import { I18n } from '@/i18n';
import EventBus from '@/shared/services/event_bus';

export default {
  props: {
    model: Object,
    close: Function,
    showClose: {
    default: true,
      type: Boolean
    }
  },

  data() {
    return {
      includeInCatchUp: true,
      volumeLevels: ["loud", "normal", "quiet"],
      isDisabled: false,
      applyToAll: this.defaultApplyToAll(),
      volume: this.defaultVolume()
    };
  },

  computed: {
    formChanged() {
      return (this.volume !== this.defaultVolume()) || (this.applyToAll !== this.defaultApplyToAll());
    },

    title() {
      switch (this.model.constructor.singular) {
      case 'discussion': return this.model.title;
      case 'membership': return this.model.group().name;
      case 'user':       return this.model.name;
      }
    }
  },

  methods: {
    submit() {
      this.model.saveVolume(this.volume, this.applyToAll)
      .then(() => {
        Flash.success('change_volume_form.saved');
        EventBus.$emit('closeModal'); 
      });
    },

    defaultApplyToAll() {
      if (this.model.isA('user')) { return true; } else { return false; }
    },

    defaultVolume() {
      switch (this.model.constructor.singular) {
      case 'discussion': return this.model.volume();
      case 'membership': return this.model.volume;
      case 'user':       return this.model.defaultMembershipVolume;
      }
    },

    labelFor(volume) {
      return I18n.global.t(`change_volume_form.simple.${volume}_explain`) + ' ('+I18n.global.t(`change_volume_form.simple.${volume}`)+')';
    },

    translateKey(key) {
      if (this.model.isA('user')) {
        return "change_volume_form.all_groups";
      } else {
        return `change_volume_form.${key || this.model.constructor.singular}`;
      }
    },

    groupName() {
      if (this.model.groupName) {
        return this.model.groupName();
      } else {
        return '';
      }
    },
    openGroupVolumeModal() {
      EventBus.$emit('closeModal');
      setTimeout(() => GroupService.actions(this.model.group(), this).change_volume.perform());
    },

    openUserPreferences() {
      EventBus.$emit('closeModal');
      this.$router.push('/email_preferences');
    }
  }
};

</script>
<template lang="pug">
v-card.change-volume-form(:title="$t(translateKey() + '.title', { title: title } )")
  template(v-slot:append)
    dismiss-modal-button(v-if="showClose")
  v-card-text
    p(v-t="'change_volume_form.simple.question'")
    v-radio-group.text-lowercase.mb-4(hide-details v-model='volume')
      v-radio.volume-loud(value='loud' :label="labelFor('loud')")
      v-radio.volume-normal(value='normal' :label="labelFor('normal')")
      v-radio.volume-quiet(value='quiet' :label="labelFor('quiet')")

    v-alert(v-if="model.isA('discussion')" dense text type="info")
      span(v-t="'change_volume_form.explain_scope.thread'")
    v-alert(v-if="model.isA('membership')" dense text type="info" v-t="'change_volume_form.explain_scope.group'")
    div(v-if="model.isA('membership') && model.group().parentOrSelf().hasSubgroups()")
      v-checkbox#apply-to-all.mb-4(v-if="model.isA('membership')" v-model='applyToAll', :label="$t('change_volume_form.membership.apply_to_organization', { organization: model.group().parentOrSelf().name })" hide-details)

    p.mt-4(v-if="model.isA('discussion')")
      a(@click="openGroupVolumeModal()" v-t="'change_volume_form.discussion.group'")
    p.mt-4(v-if="model.isA('membership')")
      a(@click="openUserPreferences()" v-t="'change_volume_form.discussion.user'")
  v-card-actions(align-center)
    help-link(path="en/user_manual/users/email_settings/#group-email-notification-settings")
    v-spacer
    v-btn.change-volume-form__submit(type='button', :disabled='!formChanged', v-t="'common.action.update'" @click='submit()' color="primary")
</template>
