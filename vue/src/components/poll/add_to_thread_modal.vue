<script lang="js">
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import AbilityService from '@/shared/services/ability_service';
import Flash   from '@/shared/services/flash';
import EventBus          from '@/shared/services/event_bus';
import { sortBy, debounce, escapeRegExp } from 'lodash-es';

export default {
  data() {
    return {
      selectedDiscussion: null,
      searchFragment: '',
      searchResults: [],
      groupId: this.poll.groupId,
      groups: sortBy(Session.user().groups(), 'fullName'),
      loading: false
    };
  },

  props: {
    poll: Object
  },

  mounted() {
    Records.discussions.fetch({
      path: 'dashboard',
      params: {
        per: 50
    }}).then(() => this.getSuggestions());
  },

  methods: {
    getSuggestions() {
      this.searchResults = Records.discussions.collection.chain()
        .find({groupId: this.groupId})
        .where(d => !!AbilityService.canStartPoll(d))
        .simplesort('id', true)
        .data();
    },

    submit() {
      this.poll.addToThread(this.selectedDiscussion.id).then(() => {
        Flash.success('add_poll_to_thread_modal.success', {pollType: this.poll.translatedPollType()});
        EventBus.$emit('closeModal');
      });
    },

    fetch: debounce(function() {
      if (!this.searchFragment) { return; }
      this.loading = true;
      Records.discussions.search(this.groupId, this.searchFragment).then(data => {
        this.loading = false;
        this.searchResults = Records.discussions.collection.chain()
          .find({groupId: this.groupId})
          .find({title: { $regex: [escapeRegExp(this.searchFragment), 'i'] }})
          .where(d => !!AbilityService.canStartPoll(d))
          .simplesort('title')
          .data();
      });
    } , 500)
  },

  watch: {
    searchFragment: 'fetch',
    groupId: 'getSuggestions'
  }
}

</script>
<template lang="pug">
v-card
  submit-overlay(:value='poll.processing')
  v-card-title
    h1.text-h5(tabindex="-1" v-t="'action_dock.add_poll_to_thread'")
    v-spacer
    dismiss-modal-button(aria-hidden='true')
  v-card-text
    v-select(v-model="groupId" :items="groups" item-text="fullName" item-value="id")
    v-autocomplete.add-to-thread-modal__search(hide-no-data return-object v-model="selectedDiscussion" :search-input.sync="searchFragment" :items="searchResults" item-text="title" :placeholder="$t('discussion_fork_actions.search_placeholder')" :label="$t('discussion_fork_actions.move_to_existing_thread')" :loading="loading")
  v-card-actions
    v-spacer
    v-btn.add-to-thread-modal__submit(color="primary" @click="submit()" :disabled="!selectedDiscussion" :loading="poll.processing")
      span(v-t="'common.action.save'")
</template>
