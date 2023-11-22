<script lang="js">
import Session        from '@/shared/services/session';
import AbilityService from '@/shared/services/ability_service';
import AppConfig from '@/shared/services/app_config';
import Records from '@/shared/services/records';
import Flash   from '@/shared/services/flash';
export default {
  props: {
    discussion: Object,
    close: Function
  },
  data() {
    return {clone: this.discussion.clone()};
  },
  methods: {
    submit() {
      this.clone.save().then(() => {
        this.close();
        Flash.success("discussion_form.messages.updated");
      });
    }
  }
};
</script>

<template>

<v-card class="thread-arrangement-form">
  <submit-overlay :value="discussion.processing"></submit-overlay>
  <v-card-title><span v-t="'thread_arrangement_form.title'"></span>
    <v-spacer></v-spacer>
    <dismiss-modal-button aria-hidden="true" :close="close"></dismiss-modal-button>
  </v-card-title>
  <div class="px-4">
    <v-alert dense="dense" text="text" type="info" v-t="'thread_arrangement_form.for_everyone'"></v-alert>
    <v-card-subtitle v-t="'thread_arrangement_form.sorting'"></v-card-subtitle>
    <v-radio-group v-model="clone.newestFirst">
      <v-radio :value="false">
        <template v-slot:label="v-slot:label"><strong v-t="'thread_arrangement_form.earliest'"></strong>
          <space></space>-
          <space></space><span v-t="'thread_arrangement_form.earliest_description'"></span>
        </template>
      </v-radio>
      <v-radio :value="true">
        <template v-slot:label="v-slot:label"><strong v-t="'thread_arrangement_form.latest'"></strong>
          <space></space>-
          <space></space><span v-t="'thread_arrangement_form.latest_description'"></span>
        </template>
      </v-radio>
    </v-radio-group>
    <v-subheader v-t="'thread_arrangement_form.replies'"></v-subheader>
    <v-radio-group v-model="clone.maxDepth">
      <v-radio :value="1">
        <template v-slot:label="v-slot:label"><strong v-t="'thread_arrangement_form.linear'"></strong>
          <space></space>-
          <space></space><span v-t="'thread_arrangement_form.linear_description'"></span>
        </template>
      </v-radio>
      <v-radio :value="2">
        <template v-slot:label="v-slot:label"><strong v-t="'thread_arrangement_form.nested_once'"></strong>
          <space></space>-
          <space></space><span v-t="'thread_arrangement_form.nested_once_description'"></span>
        </template>
      </v-radio>
      <v-radio :value="3">
        <template v-slot:label="v-slot:label"><strong v-t="'thread_arrangement_form.nested_twice'"></strong>
          <space></space>-
          <space></space><span v-t="'thread_arrangement_form.nested_twice_description'"></span>
        </template>
      </v-radio>
    </v-radio-group>
    <v-alert type="warning" v-if="clone.maxDepth != discussion.maxDepth" v-t="'thread_arrangement_form.changing_nesting_is_slow'"></v-alert>
  </div>
  <v-card-actions>
    <v-spacer></v-spacer>
    <v-btn color="primary" @click="submit()" v-t="'common.action.save'" :loading="clone.processing"></v-btn>
  </v-card-actions>
</v-card>
</template>
