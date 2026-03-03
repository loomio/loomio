<script lang="js">
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import AbilityService from '@/shared/services/ability_service';
import Flash   from '@/shared/services/flash';
import EventBus          from '@/shared/services/event_bus';
import { sortBy, debounce, escapeRegExp } from 'lodash-es';
import UrlFor from '@/mixins/url_for';

export default {
  mixins: [UrlFor],
  data() {
    return {
      selectedDiscussion: null,
      searchFragment: '',
      searchResults: [],
      groupId: this.discussion.groupId,
      groups: sortBy(Session.user().groups(), 'fullName'),
      loading: false
    };
  },

  props: {
    discussion: Object
  },

  mounted() {
    Records.discussions.fetch({
      path: 'dashboard',
      params: {
        exclude_types: 'user group poll',
        per: 50
      }}).then(() => this.getSuggestions());
  },

  methods: {
    getSuggestions() {
      this.searchResults = Records.discussions.collection.chain()
        .find({groupId: this.groupId})
        .where(d => d.topic() && AbilityService.canStartPoll(d.topic()))
        .simplesort('id', true)
        .data();
    },

    resetSourceDiscussion() {
      this.discussion.update({forkedEventIds: []});
    },

    startNewThread() {
      this.selectedDiscussion = Records.discussions.build({groupId: this.groupId});
      this.selectedDiscussion.update({forkedEventIds: this.discussion.forkedEventIds});
      this.resetSourceDiscussion();
      EventBus.$emit('openModal', {
        component: 'DiscussionForm',
        props: {
          discussion: this.selectedDiscussion
        }
      }
      );
    },

    submit() {
      this.loading = true;
      const topic = this.selectedDiscussion.topic();
      topic.moveComments(this.discussion.forkedEventIds).then(() => {
        this.loading = false;
        this.resetSourceDiscussion();
        EventBus.$emit('closeModal');
        Flash.success("discussion_fork_actions.moved");
        this.$router.push(this.urlFor(this.selectedDiscussion));
      });
    },

    fetch: debounce(function() {
      if (!this.searchFragment) { return; }
      this.loading = true;
      Records.discussions.search(this.groupId, this.searchFragment).then(data => {
        this.loading = false;
        this.searchResults = Records.discussions.collection.chain()
          .find({groupId: this.groupId})
          .find({id: { $ne: this.discussion.id } })
          .find({title: { $regex: [escapeRegExp(this.searchFragment), 'i'] }})
          .where(d => d.topic() && AbilityService.canAddComment(d.topic()))
          .simplesort('title')
          .data();
      });
    } , 500)
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
    v-autocomplete(hide-no-data return-object v-model="selectedDiscussion" :search-input.sync="searchFragment" :items="searchResults" item-title="title" :placeholder="$t('discussion_fork_actions.search_placeholder')" :label="$t('discussion_fork_actions.move_to_existing_thread')" :loading="loading")
  v-card-actions
    v-spacer
    v-btn(color="primary" outlined @click="startNewThread()" :loading="discussion.processing")
      span(v-t="'discussion_fork_actions.start_new_thread'")
    v-btn(color="primary" @click="submit()" :disabled="!selectedDiscussion" :loading="discussion.processing")
      span(v-t="'common.action.save'")
</template>
