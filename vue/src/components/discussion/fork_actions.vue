<script lang="js">
import Records      from '@/shared/services/records';
import openModal      from '@/shared/helpers/open_modal';
import {mdiCallSplit} from '@mdi/js';

export default {
  props: {
    topic: Object
  },
  data() {
    return { mdiCallSplit }
  },
  methods: {
    openMoveCommentsModal() {
      openModal({
        component: 'MoveCommentsModal',
        props: {
          topic: this.topic
        }
      });
    }
  },
  computed: {
    styles() {
      // const { bar, top } = this.$vuetify.application;
      return{
        // display: 'flex',
        position: 'sticky',
        top: `64px`,
        zIndex: 1
      };
    }
  }
};
</script>

<template lang='pug'>
v-banner.discussion-fork-actions(lines="one" sticky :elevation="4" v-if='topic.forkedEventIds.length' :icon="mdiCallSplit" color="primary" :style="styles")
  v-banner-text
    span(v-t="'discussion_fork_actions.helptext'")
  template(v-slot:actions)
    .d-flex.align-center
      v-btn.discussion-fork-actions__move(color="primary" @click="openMoveCommentsModal()" v-t="'discussion_fork_actions.move'")
      v-btn(icon @click='topic.forkedEventIds = []')
        common-icon(name="mdi-close")
</template>
