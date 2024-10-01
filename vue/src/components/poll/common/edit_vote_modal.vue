<script lang="js">
import EventBus from '@/shared/services/event_bus';
import PollCommonDirective from '@/components/poll/common/directive.vue';
import Flash   from '@/shared/services/flash';

export default {
  props: {
    stance: Object
  },
  components: {
    PollCommonDirective
  },

  methods: {
    submit() {
      const actionName = !this.stance.castAt ? 'created' : 'updated';
      this.stance.save().then(() => {
        Flash.success(`poll_${this.stance.poll().pollType}_vote_form.stance_${actionName}`);
        EventBus.$emit('closeModal')
      }).catch(error => true);
    }
  },
  computed: {
    title() {
      return this.stance.castAt ? 'poll_common.change_your_response' : 'poll_common.have_your_say'
    }
  }

};
</script>
<template lang="pug">
v-card.poll-common-edit-vote-modal(:title="$t(title)")
  template(v-slot:append)
    dismiss-modal-button(:model="stance")
      
  v-sheet.pa-4
    poll-common-directive(name="vote-form" :stance="stance")
</template>
