<script lang="js">
import Session from '@/shared/services/session';
import EventBus from '@/shared/services/event_bus';
import { uniq } from 'lodash-es';

export default {
  props: {
    model: Object
  },

  data() {
    return {items: []};
  },

  mounted() {
    return this.query();
  },

  methods: {
    query() {
      this.items = uniq(this.model.group().tags().map(t => t.name).concat(this.model.group().parentOrSelf().tags().filter(t => t.taggingsCount).map(t => t.name)));
    },

    colorFor(name) {
      return (
        this.model.group().tags().find(t => t.name === name) || 
        this.model.group().parentOrSelf().tags().find(t => t.name === name) ||
        {}
      ).color;
    },

    remove(name) {
      this.model.tags.splice(this.model.tags.indexOf(name), 1);
    }
  },

  watch: {
    'model.groupId': 'query'
  },

  computed: {
    actor() {
      return Session.user();
    }
  }
};

</script>

<template>

<v-combobox class="tags-field__input" multiple="multiple" hide-selected="hide-selected" v-model="model.tags" :label="$t('loomio_tags.tags')" :items="items">
  <template v-slot:selection="data">
    <v-chip class="chip--select-multi" :key="JSON.stringify(data.item)" :value="data.item" close="close" outlined="outlined" :color="colorFor(data.item)" @click:close="remove(data)"><span>{{ data.item }}</span></v-chip>
  </template>
  <template v-slot:item="data">
    <v-chip class="chip--select-multi" outlined="outlined" :color="colorFor(data.item)"><span>{{ data.item }}</span></v-chip>
  </template>
</v-combobox>
</template>
