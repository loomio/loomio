<script lang="js">
import Session from '@/shared/services/session';
import ChangeVolumeModalMixin from '@/mixins/change_volume_modal';
import GroupService from '@/shared/services/group_service';
import Flash from '@/shared/services/flash';

export default {
  mixins: [ChangeVolumeModalMixin],
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
        this.closeModal();
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
      return this.$t(`change_volume_form.simple.${volume}_explain`) + ' ('+this.$t(`change_volume_form.simple.${volume}`)+')';
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
      this.closeModal();
      setTimeout(() => GroupService.actions(this.model.group(), this).change_volume.perform());
    },

    openUserPreferences() {
      this.closeModal();
      this.$router.push('/email_preferences');
    }
  }
};

</script>
<template>

<v-card class="change-volume-form">
  <form>
    <submit-overlay :value="model.processing"></submit-overlay>
    <v-card-title>
      <h1 class="headline change-volume-form__title" v-t="{ path: translateKey() + '.title', args: { title: title } }"></h1>
      <v-spacer></v-spacer>
      <dismiss-modal-button v-if="showClose"></dismiss-modal-button>
    </v-card-title>
    <v-card-text>
      <p v-t="'change_volume_form.simple.question'"></p>
      <v-radio-group class="text-lowercase mb-4" hide-details="hide-details" v-model="volume">
        <v-radio class="volume-loud" value="loud" :label="labelFor('loud')"></v-radio>
        <v-radio class="volume-normal" value="normal" :label="labelFor('normal')"></v-radio>
        <v-radio class="volume-quiet" value="quiet" :label="labelFor('quiet')"></v-radio>
      </v-radio-group>
      <v-alert v-if="model.isA('discussion')" dense="dense" text="text" type="info"><span v-t="'change_volume_form.explain_scope.thread'"></span></v-alert>
      <v-alert v-if="model.isA('membership')" dense="dense" text="text" type="info" v-t="'change_volume_form.explain_scope.group'"></v-alert>
      <div v-if="model.isA('membership') && model.group().parentOrSelf().hasSubgroups()">
        <v-checkbox class="mb-4" id="apply-to-all" v-if="model.isA('membership')" v-model="applyToAll" :label="$t('change_volume_form.membership.apply_to_organization', { organization: model.group().parentOrSelf().name })" hide-details="hide-details"></v-checkbox>
      </div>
      <p class="mt-4" v-if="model.isA('discussion')"><a @click="openGroupVolumeModal()" v-t="'change_volume_form.discussion.group'"></a></p>
      <p class="mt-4" v-if="model.isA('membership')"><a @click="openUserPreferences()" v-t="'change_volume_form.discussion.user'"></a></p>
    </v-card-text>
    <v-card-actions align-center="align-center">
      <help-link path="en/user_manual/users/email_settings/#group-email-notification-settings"></help-link>
      <v-spacer></v-spacer>
      <v-btn class="change-volume-form__submit" type="button" :disabled="!formChanged" v-t="'common.action.update'" @click="submit()" color="primary"></v-btn>
    </v-card-actions>
  </form>
</v-card>
</template>
