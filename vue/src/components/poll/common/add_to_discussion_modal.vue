<script lang="js">
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';
import { sortBy, debounce } from 'lodash-es';
import UrlFor from '@/mixins/url_for';

export default {
  mixins: [UrlFor],

  props: {
    poll: Object
  },

  data() {
    return {
      selectedTopic: null,
      searchFragment: '',
      searchResults: [],
      groupId: this.poll.topic().groupId,
      groups: sortBy(Session.user().groups(), 'fullName'),
      loading: false
    };
  },

  mounted() {
    this.getSuggestions();
  },

  methods: {
    canMoveTo(topic) {
      return topic.id !== this.poll.topicId &&
             topic.topicableType === 'Discussion' &&
             topic.adminsInclude(Session.user());
    },

    getSuggestions() {
      this.loading = true;
      Records.topics.fetch({
        params: {
          group_id: this.groupId,
          topicable_type: 'Discussion',
          exclude_types: 'reaction',
          per: 50
        }
      }).then(() => {
        this.loading = false;
        this.searchResults = Records.topics.collection.chain()
          .find({groupId: this.groupId, topicableType: 'Discussion'})
          .where(t => this.canMoveTo(t))
          .simplesort('lastActivityAt', true)
          .data();
      });
    },

    submit() {
      const event = this.poll.createdEvent();
      if (!event) { return; }

      this.loading = true;
      this.selectedTopic.moveComments([event.id]).then(() => {
        this.loading = false;
        Flash.success("add_poll_to_discussion_modal.success", {pollType: this.poll.translatedPollType()});
        this.$router.push(this.urlFor(this.selectedTopic)).then(() => {
          EventBus.$emit('closeModal');
        });
      });
    },

    fetch: debounce(function() {
      if (!this.searchFragment) {
        this.getSuggestions();
        return;
      }

      this.loading = true;
      Records.topics.fetch({
        params: {
          group_id: this.groupId,
          topicable_type: 'Discussion',
          q: this.searchFragment,
          per: 20
        }
      }).then(() => {
        this.loading = false;
        const frag = this.searchFragment.toLowerCase();
        this.searchResults = Records.topics.collection.chain()
          .find({groupId: this.groupId, topicableType: 'Discussion'})
          .where(t => {
            const discussion = t.discussion();
            return discussion &&
                   this.canMoveTo(t) &&
                   discussion.title.toLowerCase().includes(frag);
          })
          .simplesort('lastActivityAt', true)
          .data();
      });
    }, 500)
  },

  watch: {
    searchFragment: 'fetch',
    groupId: 'getSuggestions'
  }
};
</script>

<template lang="pug">
v-card(:title="$t('add_poll_to_discussion_modal.title')")
  template(v-slot:append)
    dismiss-modal-button(aria-hidden='true')
  v-card-text
    v-select(v-model="groupId" :items="groups" item-title="fullName" item-value="id")
    v-autocomplete(hide-no-data return-object v-model="selectedTopic" :search-input.sync="searchFragment" :items="searchResults" item-title="title" :placeholder="$t('discussion_fork_actions.search_placeholder')" :label="$t('add_poll_to_discussion_modal.discussion')" :loading="loading")
  v-card-actions
    v-spacer
    v-btn(color="primary" @click="submit()" :disabled="!selectedTopic" :loading="loading")
      span(v-t="'common.action.save'")
</template>
