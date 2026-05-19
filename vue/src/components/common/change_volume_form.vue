<script lang="js">
import Session from '@/shared/services/session';
import GroupService from '@/shared/services/group_service';
import Flash from '@/shared/services/flash';
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
      case 'topic':      return this.model.topicable().title;
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
      case 'topic':      return this.model.volume();
      case 'membership': return this.model.volume;
      case 'user':       return null;
      }
    },

    translateKey(key) {
      if (this.model.isA('user')) {
        return "change_volume_form.all_groups";
      } else {
        const singular = this.model.isA('topic') ? 'discussion' : this.model.constructor.singular;
        return `change_volume_form.${key || singular}`;
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
  v-card-text.px-2
    v-radio-group.mb-4(hide-details v-model='volume' :label="$t(model.isA('topic') ? 'change_volume_form.when_do_you_want_to_be_emailed_thread' : 'change_volume_form.when_do_you_want_to_be_emailed')")
      v-radio.volume-loud(value='loud' :label="$t('change_volume_form.loud_option')")
      v-radio.volume-normal(value='normal' :label="$t('change_volume_form.normal_option')")
      v-radio.volume-quiet(value='quiet' :label="$t('change_volume_form.quiet_option')")

    div(v-if="model.isA('membership') && model.group().parentOrSelf().hasSubgroups()")
      v-checkbox#apply-to-all.mb-4(v-if="model.isA('membership')" v-model='applyToAll', :label="$t('change_volume_form.membership.apply_to_organization', { organization: model.group().parentOrSelf().name })" hide-details)

    p.mt-4(v-if="model.isA('membership')")
  v-card-actions(align-center)
    help-btn(path="en/user_manual/users/email_settings/#group-email-notification-settings")
    v-spacer
    v-btn.change-volume-form__submit(variant="tonal" :disabled='!formChanged' @click='submit()' color="primary")
      span( v-t="'common.action.update'" )
</template>
