<script lang="js">
import Records  from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';

import { exact } from '@/shared/helpers/format_time';

export default {
  props: {
    model: Object,
    close: Function
  },

  created() {
    this.getVersion(this.model.versionsCount - 1);
  },

  data() {
    return {
      index: 1,
      version: null
    };
  },

  methods: {
    getVersion(index) {
      this.index = index;
      this.version = null;
      return Records.versions.fetchVersion(this.model, index).then(data => {
        this.version = Records.versions.find(data.versions[0].id);
      });
    },

    getNext() {
      if (!this.isNewest) {
        return this.getVersion(this.index + 1);
      }
    },

    getPrevious() {
      if (!this.isOldest) {
        return this.getVersion(this.index - 1);
      }
    }
  },

  computed: {
    versionDate() {
      return exact(this.version.createdAt);
    },

    isOldest() {
      return this.index === 0;
    },

    isNewest() {
      return this.index === (this.model.versionsCount - 1);
    }
  }
};

</script>

<template lang="pug">
v-card.revision-history-modal
  v-card-title
    h1.text-h5(tabindex="-1" v-t="'revision_history_modal.' + model.constructor.singular + '_header'")
    v-spacer
    dismiss-modal-button(:close="close")
  .revision-history-modal__body.pa-4
    v-layout(align-center justify-space-between)
      v-btn.revision-history-nav--previous(icon :disabled='isOldest' @click='getPrevious()')
        common-icon(name="mdi-arrow-left")

      span(v-if="version" v-t="{path: 'revision_history_modal.edit_by', args: {name: version.authorName(), date: versionDate}}")

      v-btn.revision-history-nav--next(icon :disabled='isNewest' @click='getNext()')
        common-icon(name="mdi-arrow-right")
    v-divider.mb-3
    revision-history-content(v-if='version' :model='model' :version='version')
</template>
