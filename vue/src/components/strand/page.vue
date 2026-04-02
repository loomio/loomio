<script lang="js">
import Records           from '@/shared/services/records';
import Session           from '@/shared/services/session';
import EventBus          from '@/shared/services/event_bus';
import ThreadLoader      from '@/shared/loaders/thread_loader';
import FormatDate from '@/mixins/format_date';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';
import StrandActionsPanel from './actions_panel';
import ScrollService from '@/shared/services/scroll_service';
import { mdiMenuOpen, mdiArrowULeftTop } from '@mdi/js';

export default {
  mixins: [WatchRecords, UrlFor],

  components: {
    StrandActionsPanel
  },

  data() {
    return {
      mdiMenuOpen,
      mdiArrowULeftTop,
      topic: null,
      topicable: null,
      loader: null,
      position: 0,
      group: null,
      focusMode: null,
      focusSelector: null,
      anchorSelector: null,
      anchorOffset: null,
      lastAnchorSelector: null,
      snackbar: false,
      focusedItemVisible: false
    };
  },

  mounted() {
    EventBus.$on('setAnchor', (selector, offset) => {
      this.anchorSelector = selector;
      this.anchorOffset = offset
    });

    EventBus.$on('visibleKeys', (keys) => {
      if (!this.focusSelector || !this.loader) { return true; }

      // Extract sequence ID from selector like `.sequenceId-123`
      const match = this.focusSelector.match(/\.sequenceId-(\d+)/);
      if (!match) { return true; }

      const sequenceId = parseInt(match[1]);
      const event = Records.events.find({ topicId: this.topic.id, sequenceId: sequenceId })[0];
      if (!event) { return false; }
      this.focusedItemVisible = keys.includes(event.positionKey);
    })

    this.init();
  },

  destroyed() {
    EventBus.$off('setFocus');
  },

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

    scrollToFocused() {
      if (this.focusSelector) {
        ScrollService.scrollTo(this.focusSelector, this.anchorOffset);
      }
    },

    init() {
      const isPoll = this.$route.path.startsWith('/p/');
      const collection = isPoll ? Records.polls : Records.discussions;
      const fetchParams = isPoll ? {} : {exclude_types: 'poll outcome'};

      collection.findOrFetchById(this.$route.params.key, fetchParams).then(model => {
        if (model.group() && model.group().newHost) { window.location.host = model.group().newHost; }
        this.topicable = model;
        this.topic = model.topic();
        this.loader = new ThreadLoader(this.topicable);

        this.respondToRoute();

        EventBus.$emit('currentComponent', {
          focusHeading: false,
          page: 'discussionPage',
          topic: this.topic,
          group: this.topic.group(),
          title: this.topicable.title
        });

        this.watchRecords({
          key: 'strand'+this.topic.id,
          collections: ['events'],
          query: () => {
            this.loader.updateCollection();
            this.$nextTick(() => this.scrollToAnchorIfNew());
          }
        });
      }).catch(function(error) {
        if (error.status) {
          EventBus.$emit('pageError', error);
          if ((error.status === 403) && !Session.isSignedIn()) { EventBus.$emit('openAuthModal'); }
        } else {
          console.error(error);
        }
      });
    },

    loadContent() {
      if (!this.topicable) { return; }
      if (this.topicable.key !== this.$route.params.key) { return; }

      this.focusMode = null;
      this.focusSelector = null;
      this.anchorSelector = null;
      this.anchorOffset = null;

      this.loader.addContextRule();
      this.loader.addLoadMyStuffRule();

      if (this.topic.itemsCount <= 1) {
        this.loader.addLoadNewestRule();
        // this.anchorSelector = '#strand-page';
        return;
      }

      if (Object.keys(this.$route.params).includes('sequence_id')) {
        const sequenceId = parseInt(this.$route.params.sequence_id);
        this.loader.addLoadSequenceIdRule(sequenceId);
        this.focusSelector = `.sequenceId-${sequenceId}`;
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
        this.loader.addLoadNewestRule();
        this.focusMode = 'unread';
        this.anchorSelector = `.sequenceId-${parseInt(this.loader.firstUnreadSequenceId())}`;
        return;
      }

      if (Object.keys(this.$route.query).includes('newest')) {
        this.loader.clearRules();
        this.loader.addLoadNewestRule();
        this.focusMode = 'newest';
        this.focusSelector = `.sequenceId-${parseInt(this.topic.lastSequenceId())}`;
        return;
      }

      // never been read before
      if (!this.topic.lastReadAt) {
        if (this.topic.newestFirst) {
          this.loader.addLoadNewestRule();
        } else {
          this.loader.addLoadOldestRule();
        }
        this.anchorSelector = "#strand-page";
        return;
      }

      if (this.loader.firstUnreadSequenceId()) {
        this.loader.addLoadUnreadRule();
        this.loader.addLoadNewestRule();
        this.focusMode = 'unread';
        this.anchorSelector = `.sequenceId-${parseInt(this.loader.firstUnreadSequenceId())}`;
        return;
      } else {
        this.loader.addLoadNewestRule();
        this.focusMode = 'newest';
        this.anchorSelector = `.sequenceId-${parseInt(this.topic.lastSequenceId())}`;
        return;
      }
    },

    respondToRoute() {
      this.loadContent();
      this.snackbar = !!this.focusMode;

      if (this.$route.query.current_action) {
        this.anchorSelector = '.actions-panel-end';
      } else {
        if (!this.anchorSelector) {
          this.anchorSelector = this.focusSelector;
          this.anchorOffset = null;
        }
      }

      this.scrollToAnchorIfPresent();

      this.loader.fetch();
    },

    scrollToAnchorIfPresent() {
      if (document.querySelector(this.anchorSelector)) {
        ScrollService.scrollTo(this.anchorSelector, this.anchorOffset);
      }
    },

    scrollToAnchorIfNew() {
      if (this.lastAnchorSelector !== this.anchorSelector) {
        ScrollService.scrollTo(this.anchorSelector, this.anchorOffset);
        this.lastAnchorSelector = this.anchorSelector;
      }
    },
  }
};

</script>

<template lang="pug">
.strand-page
  v-main
    v-container.max-width-800.px-0.px-sm-3#strand-page(v-if="topicable")
      discussion-fork-actions(v-if="topicable.constructor.singular === 'discussion'" :discussion='topicable' :key="'fork-actions'+ topicable.id")
      v-sheet.strand-card.thread-card.mb-8.pb-4.rounded(elevation=1)
        v-snackbar(v-if="focusMode" v-model="snackbar" location="bottom center" color="info")
          div.text-center
            span.text-center(v-if="focusMode == 'unread'" v-t="'strand_nav.showing_unread'")
            span.text-center(v-if="focusMode == 'newest'" v-t="'strand_nav.showing_latest'")
        strand-list.pr-1.pr-sm-3.px-sm-2(:loader="loader" :collection="loader.collection" :focus-selector="focusSelector" :focus-mode="focusMode")
        strand-actions-panel(:topic="topic")
  strand-toc-nav(v-if="loader" :topic="topic" :loader="loader" :key="topic.id" :focus-mode="focusMode" :focus-selector="focusSelector")
  v-fab(v-if="focusSelector && !focusedItemVisible" icon app extended :text="$t('strand_nav.recenter')" location="bottom center" @click="scrollToFocused" color="accent" variant="elevated")
    v-icon(:icon="mdiArrowULeftTop")
  v-fab(v-if="!$vuetify.display.mdAndUp" icon app location="bottom right" @click="openThreadNav" color="primary" variant="tonal")
    v-icon(:icon="mdiMenuOpen" )
</template>
