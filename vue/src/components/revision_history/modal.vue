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

<template>

<v-card class="revision-history-modal">
  <v-card-title>
    <h1 class="headline" tabindex="-1" v-t="'revision_history_modal.' + model.constructor.singular + '_header'"></h1>
    <v-spacer></v-spacer>
    <dismiss-modal-button :close="close"></dismiss-modal-button>
  </v-card-title>
  <div class="revision-history-modal__body pa-4">
    <v-layout align-center="align-center" justify-space-between="justify-space-between">
      <v-btn class="revision-history-nav--previous" icon="icon" :disabled="isOldest" @click="getPrevious()">
        <common-icon name="mdi-arrow-left"></common-icon>
      </v-btn><span v-if="version" v-t="{path: 'revision_history_modal.edit_by', args: {name: version.authorName(), date: versionDate}}"></span>
      <v-btn class="revision-history-nav--next" icon="icon" :disabled="isNewest" @click="getNext()">
        <common-icon name="mdi-arrow-right"></common-icon>
      </v-btn>
    </v-layout>
    <v-divider class="mb-3"></v-divider>
    <revision-history-content v-if="version" :model="model" :version="version"></revision-history-content>
  </div>
</v-card>
</template>
