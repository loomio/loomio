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
      emailVolume: this.defaultEmailVolume(),
      pushVolume: this.defaultPushVolume()
    };
  },

  computed: {
    formChanged() {
      return (this.emailVolume !== this.defaultEmailVolume()) ||
             (this.pushVolume !== this.defaultPushVolume()) ||
             (this.applyToAll !== this.defaultApplyToAll());
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
      this.model.saveVolume(this.emailVolume, this.pushVolume, this.applyToAll)
      .then(() => {
        Flash.success('change_volume_form.saved');
        EventBus.$emit('closeModal');
      });
    },

    defaultApplyToAll() {
      if (this.model.isA('user')) { return true; } else { return false; }
    },

    defaultEmailVolume() {
      switch (this.model.constructor.singular) {
      case 'discussion': return this.model.discussionReaderEmailVolume;
      case 'membership': return this.model.emailVolume;
      case 'user':       return null;
      }
    },

    defaultPushVolume() {
      switch (this.model.constructor.singular) {
      case 'discussion': return this.model.discussionReaderPushVolume;
      case 'membership': return this.model.pushVolume;
      case 'user':       return null;
      }
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
    v-alert(v-if="model.isA('discussion')" variant="tonal" type="info")
      span(v-t="'change_volume_form.explain_scope.thread'")
      br
      a(@click="openGroupVolumeModal()" v-t="'change_volume_form.discussion.group'")
    v-alert(v-if="model.isA('membership')" variant="tonal" type="info")
      span(v-t="'change_volume_form.explain_scope.group'")
      br
      a(@click="openUserPreferences()" v-t="'change_volume_form.discussion.user'")
    v-radio-group.mb-4(hide-details v-model='emailVolume' :label="$t('change_volume_form.email_volume_label')")
      v-radio.volume-loud(value='loud' :label="$t('change_volume_form.loud_desc')")
      v-radio.volume-normal(value='normal' :label="$t('change_volume_form.normal_desc')")
      v-radio.volume-quiet(value='quiet' :label="$t('change_volume_form.quiet_desc')")

    v-radio-group.mb-4(hide-details v-model='pushVolume' :label="$t('change_volume_form.push_volume_label')")
      v-radio.volume-loud(value='loud' :label="$t('change_volume_form.loud_desc')")
      v-radio.volume-normal(value='normal' :label="$t('change_volume_form.normal_desc')")
      v-radio.volume-quiet(value='quiet' :label="$t('change_volume_form.quiet_desc')")

    div(v-if="model.isA('membership') && model.group().parentOrSelf().hasSubgroups()")
      v-checkbox#apply-to-all.mb-4(v-if="model.isA('membership')" v-model='applyToAll', :label="$t('change_volume_form.membership.apply_to_organization', { organization: model.group().parentOrSelf().name })" hide-details)

    p.mt-4(v-if="model.isA('discussion')")
    p.mt-4(v-if="model.isA('membership')")
  v-card-actions(align-center)
    help-btn(path="en/user_manual/users/email_settings/#group-email-notification-settings")
    v-spacer
    v-btn.change-volume-form__submit(:disabled='!formChanged' @click='submit()' color="primary")
      span( v-t="'common.action.update'" )
</template>
