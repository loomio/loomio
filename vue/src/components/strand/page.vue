<script lang="js">
import Records           from '@/shared/services/records';
import Session           from '@/shared/services/session';
import EventBus          from '@/shared/services/event_bus';
import ThreadLoader      from '@/shared/loaders/thread_loader';
import FormatDate from '@/mixins/format_date';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';
import StrandActionsPanel from './actions_panel';
import { mdiMap } from '@mdi/js';

export default {
  mixins: [FormatDate, WatchRecords, UrlFor],
  components: {
    StrandActionsPanel
  },
  data() {
    return {
      mdiMap,
      discussion: null,
      loader: null,
      position: 0,
      group: null,
      discussionFetchError: null,
      focusHelp: null,
      focusSelector: null,
      lastFocusSelector: null,
      snackbar: false
    };
  },

  mounted() { this.init(); },

  watch: {
    '$route.params.key': 'init',
    '$route.params.sequence_id': 'respondToRoute',
    '$route.params.comment_id': 'respondToRoute',
    '$route.query.p': 'respondToRoute',
    '$route.query.k': 'respondToRoute',
    '$route.query.current_action': 'respondToRoute',
    '$route.query.unread': 'respondToRoute',
    '$route.query.newest': 'respondToRoute',
  },

  methods: {
    openThreadNav() {
      EventBus.$emit('toggleThreadNav')
    },
    init() {
      Records.discussions.findOrFetchById(this.$route.params.key, {exclude_types: 'poll outcome'}).then(discussion => {
        if (discussion.group().newHost) { window.location.host = discussion.group().newHost; }
        this.discussion = discussion;
        this.loader = new ThreadLoader(this.discussion);

        this.respondToRoute();

        EventBus.$emit('currentComponent', {
          focusHeading: false,
          page: 'discussionPage',
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

    loadContent() {
      if (!this.discussion) { return; }
      if (this.discussion.key !== this.$route.params.key) { return; }

      this.focusSelector = null;
      this.focusHelp = null;

      this.loader.addContextRule();

      if (this.discussion.itemsCount === 0) {
        this.focusSelector = '#strand-page';
        return;
      }

      if (this.$route.params.sequence_id) {
        this.loader.addLoadSequenceIdRule(parseInt(this.$route.params.sequence_id));
        this.focusSelector = `.sequenceId-${parseInt(this.$route.params.sequence_id)}`;
        return;
      }

      if (this.$route.params.comment_id) {
        this.loader.addLoadCommentRule(parseInt(this.$route.params.comment_id));
        this.loader.addLoadNewestRule();
        this.focusSelector = `#comment-${parseInt(this.$route.params.comment_id)}`;
        return;
      }

      if (Object.keys(this.$route.query).includes('unread')) {
        this.loader.clearRules();
        this.loader.addLoadUnreadRule();
        this.focusHelp = 'strand_nav.showing_unread_activity';
        this.focusSelector = `.sequenceId-${parseInt(this.loader.firstUnreadSequenceId())}`;
        return;
      }

      if (Object.keys(this.$route.query).includes('newest')) {
        this.loader.clearRules();
        this.loader.addLoadNewestRule();
        this.focusHelp = 'strand_nav.showing_latest_activity';
        this.focusSelector = `.sequenceId-${parseInt(this.discussion.lastSequenceId())}`;
        return;
      }

      // never been read before
      if (!this.discussion.lastReadAt) {
        if (this.discussion.newestFirst) {
          this.loader.addLoadNewestRule();
        } else {
          this.loader.addLoadOldestRule();
        }
        this.focusSelector = "#strand-page";
        return;
      }

      if (this.loader.firstUnreadSequenceId()) {
        this.loader.addLoadUnreadRule();
        this.focusHelp = 'strand_nav.showing_unread_activity';
        this.focusSelector = `.sequenceId-${parseInt(this.loader.firstUnreadSequenceId())}`;
        return;
      } else {
        this.loader.addLoadNewestRule();
        this.focusHelp = 'strand_nav.showing_latest_activity';
        this.focusSelector = `.sequenceId-${parseInt(this.discussion.lastSequenceId())}`;
        return;
      }
    },

    respondToRoute() {
      this.loadContent();
      this.snackbar = !!this.focusHelp;

      if (this.$route.query.current_action) {
        this.focusSelector = '.actions-panel-end';
      }

      // this.scrollToFocusIfPresent();

      this.loader.fetch().finally(() => {
        setTimeout(() => this.scrollToFocusUnlessFocused());
      }).catch(res => {
        console.log('promises failed', res);
      });
    },

    scrollToFocusIfPresent() {
      if (document.querySelector(this.focusSelector)) {
        this.scrollTo(this.focusSelector);
        this.lastFocusSelector = this.focusSelector;
      }
    },

    scrollToFocusUnlessFocused() {
      if (this.lastFocusSelector !== this.focusSelector) {
        this.scrollTo(this.focusSelector);
        this.lastFocusSelector = this.focusSelector;
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
      if (this.lastFocusSelector &&
         (el = document.querySelector(this.lastFocusSelector) &&
         !this.elementInView(el))) {
        console.log(`refocusing ${this.lastFocusSelector}`);
        this.scrollTo(this.lastFocusSelector);
      }
    },
  }
};

</script>

<template lang="pug">
.strand-page
  v-main
    v-container.max-width-800.px-0.px-sm-3#strand-page(v-if="discussion")
      v-fab(v-if="!$vuetify.display.mdAndUp" app location="bottom right" :icon="mdiMap" @click="openThreadNav")
      thread-current-poll-banner(:discussion="discussion")
      discussion-fork-actions(:discussion='discussion' :key="'fork-actions'+ discussion.id")
      v-sheet.strand-card.thread-card.mb-8.pb-4.rounded(elevation=1)
        v-snackbar(v-if="focusHelp" v-model="snackbar" location="top")
          span(v-t="focusHelp")

        strand-list.pt-3.pr-1.pr-sm-3.px-sm-2(:loader="loader" :collection="loader.collection" :focus-selector="focusSelector")
        strand-actions-panel(v-if="!loader.discussion.newestFirst" :discussion="discussion")
  strand-toc-nav(v-if="loader" :discussion="discussion" :loader="loader" :key="discussion.id" :focus-help="focusHelp" :focus-selector="focusSelector")
</template>
