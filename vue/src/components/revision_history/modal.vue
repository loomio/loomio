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
v-card.revision-history-modal(:title="$t('revision_history_modal.' + model.constructor.singular + '_header')")
  template(v-slot:append)
    dismiss-modal-button(:close="close")
  v-card-item
    .d-flex.align-center.justify-space-between
      v-btn.revision-history-nav--previous(variant="tonal" icon :disabled='isOldest' @click='getPrevious()')
        common-icon(name="mdi-arrow-left" :color="isOldest ? null : 'primary'")
      span(v-if="version" v-t="{path: 'revision_history_modal.edit_by', args: {name: version.authorName(), date: versionDate}}")
      v-btn.revision-history-nav--next(variant="tonal" icon :disabled='isNewest' @click='getNext()')
        common-icon(name="mdi-arrow-right" :color="isNewest ? null : 'primary'")
    v-divider.mb-3
    revision-history-content(v-if='version' :model='model' :version='version')
</template>
