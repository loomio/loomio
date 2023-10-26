<script lang="js">
import Records           from '@/shared/services/records';
import Session           from '@/shared/services/session';
import EventBus          from '@/shared/services/event_bus';
import AbilityService    from '@/shared/services/ability_service';
import ThreadLoader      from '@/shared/loaders/thread_loader';
import DemoBanner from '@/components/group/demo_banner';

export default {
  components: {DemoBanner},
  data() {
    return {
      discussion: null,
      loader: null,
      position: 0,
      group: null,
      discussionFetchError: null,
      lastFocus: null
    };
  },

  mounted() { this.init(); },

  watch: {
    '$route.params.key': 'init',
    '$route.params.comment_id': 'init',
    '$route.params.sequence_id': 'respondToRoute',
    '$route.params.comment_id': 'respondToRoute',
    '$route.query.p': 'respondToRoute',
    '$route.query.k': 'respondToRoute'
  },

  methods: {
    init() {
      Records.discussions.findOrFetchById(this.$route.params.key, {exclude_types: 'poll outcome'})
      .then(discussion => {
        if (discussion.group().newHost) { window.location.host = discussion.group().newHost; }
        this.discussion = discussion;
        this.loader = new ThreadLoader(this.discussion);
        this.respondToRoute();
        EventBus.$emit('currentComponent', {
          focusHeading: false,
          page: 'threadPage',
          discussion: this.discussion,
          group: this.discussion.group(),
          title: this.discussion.title
        });

        this.watchRecords({
          key: 'strand'+this.discussion.id,
          collections: ['events'],
          query: () => this.loader.updateCollection()
        });
      }).catch(function(error) {
        EventBus.$emit('pageError', error);
        if ((error.status === 403) && !Session.isSignedIn()) { EventBus.$emit('openAuthModal'); }
      });
    },

      // .catch (error) =>
      //   EventBus.$emit 'pageError', error
      //   EventBus.$emit 'openAuthModal' if error.status == 403 && !Session.isSignedIn()

    focusSelector() {
      if (this.loader.focusAttrs.newest) {
        if (this.discussion.lastSequenceId()) {
          return `.sequenceId-${this.discussion.lastSequenceId()}`;
        } else {
          return "#add-comment";
        }
      }

      if (this.loader.focusAttrs.unread) {
        if (this.loader.firstUnreadSequenceId()) {
          return `.sequenceId-${this.loader.firstUnreadSequenceId()}`;
        } else {
          return '.context-panel';
        }
      }

      if (this.loader.focusAttrs.oldest) {
        return '.context-panel';
      }

      if (this.loader.focusAttrs.commentId) {
        return `#comment-${this.loader.focusAttrs.commentId}`;
      }

      if (this.loader.focusAttrs.sequenceId) {
        return `.sequenceId-${this.loader.focusAttrs.sequenceId}`;
      }

      if (this.loader.focusAttrs.position) {
        return `.position-${this.loader.focusAttrs.position}`;
      }

      if (this.loader.focusAttrs.positionKey) {
        return `.positionKey-${this.loader.focusAttrs.positionKey}`;
      }
    },

    scrollToFocusIfPresent() {
      const selector = this.focusSelector();
      if (document.querySelector(selector)) {
        this.scrollTo(selector);
        this.lastFocus = selector;
      }
    },

    scrollToFocusUnlessFocused() {
      const selector = this.focusSelector();
      if (this.lastFocus !== selector) {
        this.scrollTo(selector);
        this.lastFocus = selector;
      }
    },

    elementInView(el) {
      const rect = el.getBoundingClientRect();
      return ((rect.top >= 0) && (rect.left >= 0) &&
       (rect.bottom <= (window.innerHeight || document.documentElement.clientHeight)) &&
       (rect.right <= (window.innerWidth || document.documentElement.clientWidth)));
    },

    refocusIfOffscreen() {
      let el;
      if (this.lastFocus &&
         (el = document.querySelector(this.lastFocus) &&
         !this.elementInView(el))) {
        console.log(`refocusing ${this.lastFocus}`);
        this.scrollTo(this.lastFocus);
      }
    },

    respondToRoute() {
      if (!this.discussion) { return; }
      if (this.discussion.key !== this.$route.params.key) { return; }
      if (this.discussion.createdEvent.childCount === 0) { return; }

      if (this.$route.query.k) {
        this.loader.addLoadPositionKeyRule(this.$route.query.k);
        this.loader.focusAttrs = {positionKey: this.$route.query.k};
      }

      if (this.$route.query.p) {
        this.loader.addLoadPositionRule(parseInt(this.$route.params.p));
        this.loader.focusAttrs = {position: this.$route.query.p};
      }

      if (this.$route.params.sequence_id) {
        this.loader.addLoadSequenceIdRule(parseInt(this.$route.params.sequence_id));
        this.loader.focusAttrs = {sequenceId: parseInt(this.$route.params.sequence_id)};
      }

      if (this.$route.params.comment_id) {
        this.loader.addLoadCommentRule(parseInt(this.$route.params.comment_id));
        this.loader.addLoadNewestRule();
        this.loader.focusAttrs = {commentId: parseInt(this.$route.params.comment_id)};
      }

      if (this.loader.rules.length === 0) {
        if (this.discussion.newestFirst) {
          this.loader.addLoadNewestRule();
          this.loader.focusAttrs = {newest: 1};
        } else {
          if (this.discussion.lastReadAt) {
            if (this.discussion.unreadItemsCount() === 0) {
              this.loader.addLoadNewestRule();
              this.loader.focusAttrs = {newest: 1};
            } else {
              this.loader.addLoadUnreadRule();
              this.loader.focusAttrs = {unread: 1};
            }
          } else {
            this.loader.addLoadOldestRule();
            this.loader.focusAttrs = {oldest: 1};
          }
        }
      }

      this.loader.addContextRule();

      this.scrollToFocusIfPresent();

      this.loader.fetch().finally(() => {
        setTimeout(() => this.scrollToFocusUnlessFocused());
      }).catch(res => {
        console.log('promises failed', res);
      });
    }
  }
};

</script>

<template lang="pug">
.strand-page
  v-main
    v-container.max-width-800.px-0.px-sm-3(v-if="discussion")
      demo-banner(:group="discussion.group()" v-if="discussion.groupId")
      //- p(v-if="$route.query.debug" v-for="rule in loader.rules") {{rule}}
      //- p loader: {{loader.focusAttrs}}
      //- p ranges: {{discussion.ranges}}
      //- p read ranges: {{loader.readRanges}}
      //- p first unread {{loader.firstUnreadSequenceId()}}
      //- p test: {{rangeSetSelfTest()}}
      thread-current-poll-banner(:discussion="discussion")
      discussion-fork-actions(:discussion='discussion', :key="'fork-actions'+ discussion.id")

      strand-card(v-if="loader", :loader="loader")
  strand-toc-nav(v-if="loader", :discussion="discussion", :loader="loader", :key="discussion.id")
</template>
