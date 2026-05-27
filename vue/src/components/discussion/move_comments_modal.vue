<script lang="js">
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import AbilityService from '@/shared/services/ability_service';
import Flash   from '@/shared/services/flash';
import EventBus          from '@/shared/services/event_bus';
import { sortBy, debounce } from 'lodash-es';
import UrlFor from '@/mixins/url_for';

export default {
  mixins: [UrlFor],
  data() {
    return {
      selectedTopic: null,
      searchFragment: '',
      searchResults: [],
      groupId: this.topic.groupId,
      groups: sortBy(Session.user().groups(), 'fullName'),
      loading: false
    };
  },

  props: {
    topic: Object
  },

  mounted() {
    this.getSuggestions();
  },

  methods: {
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
          .where(t => t.id !== this.topic.id && AbilityService.canAddComment(t))
          .simplesort('lastActivityAt', true)
          .data();
      });
    },

    resetForkedEvents() {
      this.topic.forkedEventIds = [];
    },

    startNewThread() {
      const newDiscussion = Records.discussions.build({groupId: this.groupId});
      newDiscussion.forkedEventIds = this.topic.forkedEventIds;
      this.resetForkedEvents();
      EventBus.$emit('openModal', {
        component: 'DiscussionForm',
        props: {
          discussion: newDiscussion
        }
      });
    },

    submit() {
      this.loading = true;
      this.selectedTopic.moveComments(this.topic.forkedEventIds).then(() => {
        this.loading = false;
        this.resetForkedEvents();
        EventBus.$emit('closeModal');
        Flash.success("discussion_fork_actions.moved");
        this.$router.push(this.urlFor(this.selectedTopic));
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
            const disc = t.discussion();
            return disc && t.id !== this.topic.id &&
                   disc.title.toLowerCase().includes(frag) &&
                   AbilityService.canAddComment(t);
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
v-card(:title="$t('action_dock.move_items')")
  template(v-slot:append)
    dismiss-modal-button(aria-hidden='true')
  v-card-text
    v-select(v-model="groupId" :items="groups" item-title="fullName" item-value="id")
    v-autocomplete(hide-no-data return-object v-model="selectedTopic" :search-input.sync="searchFragment" :items="searchResults" item-title="title" :placeholder="$t('discussion_fork_actions.search_placeholder')" :label="$t('discussion_fork_actions.move_to_existing_thread')" :loading="loading")
  v-card-actions
    v-spacer
    v-btn(color="primary" outlined @click="startNewThread()" :loading="loading")
      span(v-t="'discussion_fork_actions.start_new_thread'")
    v-btn(color="primary" @click="submit()" :disabled="!selectedTopic" :loading="loading")
      span(v-t="'common.action.save'")
</template>
