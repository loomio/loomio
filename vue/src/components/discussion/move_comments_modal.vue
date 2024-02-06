<script lang="js">
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import AbilityService from '@/shared/services/ability_service';
import Flash   from '@/shared/services/flash';
import EventBus          from '@/shared/services/event_bus';
import { sortBy, debounce } from 'lodash-es';

export default {
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
        .where(d => !!AbilityService.canStartPoll(d))
        .simplesort('id', true)
        .data();
    },

    resetSourceDiscussion() {
      this.discussion.update({forkedEventIds: []});
    },

    startNewThread() {
      this.selectedDiscussion = Records.discussions.build({groupId: this.groupId});
      this.setIsForking();
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
      this.selectedDiscussion.moveComments().then(() => {
        this.loading = false;
        this.resetSourceDiscussion();
        this.selectedDiscussion.update({forkedEventIds: []});
        EventBus.$emit('closeModal');
        Flash.success("discussion_fork_actions.moved");
        this.$router.push(this.urlFor(this.selectedDiscussion));
      });
    },

    setIsForking() {
      this.selectedDiscussion.update({forkedEventIds: this.discussion.forkedEventIds});
    },

    fetch: debounce(function() {
      if (!this.searchFragment) { return; }
      this.loading = true;
      Records.discussions.search(this.groupId, this.searchFragment).then(data => {
        this.loading = false;
        this.searchResults = Records.discussions.collection.chain()
          .find({groupId: this.groupId})
          .find({ id: { $ne: this.discussion.id } })
          .find({title: { $regex: [this.searchFragment, 'i'] }})
          .where(d => !!AbilityService.canAddComment(d))
          .simplesort('title')
          .data();
      });
    } , 500)
  },

  watch: {
    selectedDiscussion: 'setIsForking',
    searchFragment: 'fetch',
    groupId: 'getSuggestions'
  }
};

</script>
<template lang="pug">
v-card
  submit-overlay(:value='selectedDiscussion && selectedDiscussion.processing')
  v-card-title
    h1.text-h5(tabindex="-1" v-t="'action_dock.move_items'")
    v-spacer
    dismiss-modal-button(aria-hidden='true')
  v-card-text
    v-select(v-model="groupId" :items="groups" item-text="fullName" item-value="id")
    v-autocomplete(hide-no-data return-object v-model="selectedDiscussion" :search-input.sync="searchFragment" :items="searchResults" item-text="title" :placeholder="$t('discussion_fork_actions.search_placeholder')" :label="$t('discussion_fork_actions.move_to_existing_thread')" :loading="loading")
  v-card-actions
    v-spacer
    v-btn(color="primary" outlined @click="startNewThread()" :loading="discussion.processing")
      span(v-t="'discussion_fork_actions.start_new_thread'")
    v-btn(color="primary" @click="submit()" :disabled="!selectedDiscussion" :loading="discussion.processing")
      span(v-t="'common.action.save'")
</template>
