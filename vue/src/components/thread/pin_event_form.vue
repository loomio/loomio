<script lang="js">
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';

export default {
  props: {
    event: Object
  },

  data() {
    return {
      title: null,
      loading: false
    };
  },

  mounted() {
    this.title = (window.getSelection() && window.getSelection().toString()) || this.event.pinnedTitle || this.event.suggestedTitle();
    this.$nextTick(() => this.$refs.focus.focus());
  },

  methods: {
    submit() {
      this.loading = true;
      this.event.pin(this.title).then(() => {
        Flash.success('activity_card.event_pinned');
        EventBus.$emit('closeModal');
      });
    }
  }
};

</script>
<template>

<v-card class="pin-event-form">
  <v-card-title><span v-t="'pin_event_form.title'"></span>
    <v-spacer></v-spacer>
    <dismiss-modal-button aria-hidden="true"></dismiss-modal-button>
  </v-card-title>
  <v-card-text>
    <v-form @submit.prevent="submit()">
      <v-text-field :disabled="loading" ref="focus" v-model="title" :label="$t('pin_event_form.title_label')"></v-text-field>
    </v-form>
  </v-card-text>
  <v-card-actions>
    <v-spacer></v-spacer>
    <v-btn color="primary" @click="submit()" :loading="loading" v-t="'common.action.save'"></v-btn>
  </v-card-actions>
</v-card>
</template>
