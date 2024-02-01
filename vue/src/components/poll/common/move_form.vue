<script lang="js">
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import AbilityService from '@/shared/services/ability_service';
import EventBus from '@/shared/services/event_bus';
import Flash  from '@/shared/services/flash';
import { map } from 'lodash-es';

export default {
  props: {
    poll: Object,
    close: Function
  },

  data() {
    return {
      groupId: this.poll.groupId,
      groups: []
    };
  },

  mounted() {
    this.groups = Session.user().groups().filter(g => AbilityService.canStartPoll(g)).map(g => {
      return {
        text: g.fullName,
        value: g.id,
        disabled: (g.id === this.poll.groupId)
      };
    });
  },

  methods: {
    submit() {
      this.poll.groupId = this.groupId;
      this.poll.save().then(() => {
        Flash.success("poll_common_move_form.success", {poll_type: this.poll.translatedPollType(), group: this.poll.group().fullName});
        this.close();
      });
    }
  }
}

</script>
<template lang="pug">
v-card.poll-common-move-form(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value="poll.processing")
  v-card-title
    h1.text-h5(tabindex="-1" v-t="{path: 'poll_common_move_form.title', args: {poll_type: poll.translatedPollType() }}")
    v-spacer
    dismiss-modal-button
  v-card-text
    loading(v-if="!groups.length")
    v-select(v-if="groups.length" v-model="groupId" :items="groups" :label="$t('move_thread_form.body')")
  v-card-actions.poll-common-form-actions
    v-spacer
    v-btn.poll-common-form__submit(color="primary" @click='submit()' :loading="poll.processing")
      span(v-t="'common.action.move'")
</template>
