<script lang="js">
import Records      from '@/shared/services/records';
import openModal      from '@/shared/helpers/open_modal';
export default {
  props: {
    discussion: Object
  },
  methods: {
    openMoveCommentsModal() {
      openModal({
        component: 'MoveCommentsModal',
        props: {
          discussion: this.discussion
        }
      });
    }
  },
  computed: {
    styles() {
      const { bar, top } = this.$vuetify.application;
      return{
        display: 'flex',
        position: 'sticky',
        top: `${bar + top}px`,
        zIndex: 1
      };
    }
  }
};
</script>

<template>

<v-banner class="discussion-fork-actions" single-line="single-line" sticky="sticky" :elevation="4" v-if="discussion.forkedEventIds.length" icon="mdi-call-split" color="primary" :style="styles"><span v-t="'discussion_fork_actions.helptext'"></span>
  <template v-slot:actions="v-slot:actions">
    <v-btn color="primary" @click="openMoveCommentsModal()" v-t="'discussion_fork_actions.move'"></v-btn>
    <v-btn icon="icon" @click="discussion.forkedEventIds = []">
      <common-icon name="mdi-close"></common-icon>
    </v-btn>
  </template>
</v-banner>
</template>
