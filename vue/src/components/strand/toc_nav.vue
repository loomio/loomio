<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';
import { sortBy, last } from 'lodash-es';
import ScrollService from '@/shared/services/scroll_service';
import Session        from '@/shared/services/session';
import { mdiLightningBolt, mdiMessageBadgeOutline, mdiArrowUpThin, mdiArrowDownThin, mdiCog, mdiPlus } from '@mdi/js';

export default {
  mixins: [WatchRecords, UrlFor],
  props: {
    discussion: Object,
    loader: Object,
    focusMode: String,
    focusSelector: String
  },

  data() {
    return {
      mdiLightningBolt,
      mdiMessageBadgeOutline,
      mdiArrowUpThin,
      mdiArrowDownThin,
      mdiPlus,
      mdiCog,
      open: null,
      items: [],
      visibleKeys: [],
      baseUrl: ''
    };
  },

  computed: {
    selectedSequenceId() { return parseInt(this.$route.params.sequence_id); },
    selectedCommentId() { return parseInt(this.$route.params.comment_id); },
    isSignedIn() { return Session.isSignedIn(); },
  },

  methods: {
    lastItemSequenceId() {
      return this.items[this.items.length - 1].sequenceId;
    },

    scrollToNewest() {
      ScrollService.scrollTo(`.sequenceId-${this.discussion.lastSequenceId()}`);
    },
    scrollToUnread() {
      ScrollService.scrollTo(`.sequenceId-${this.loader.firstUnreadSequenceId()}`);
    },
    scrollToTop() {
      ScrollService.scrollTo('#strand-page');
    },
    scrollToBottom() {
      ScrollService.scrollTo(`.positionKey-${last(this.items).key}`);
    },

    scrollToSequenceId(id) {
      ScrollService.scrollTo(`.sequenceId-${id}`);
    },

    buildItems(bootData) {
      const itemsHash = {};

      this.baseUrl = this.urlFor(this.discussion);
      // parser = new DOMParser()
      // doc = parser.parseFromString(@context, 'text/html')
      // headings = Array.from(doc.querySelectorAll('h1,h2,h3')).map (el) =>
      //   {id: el.id, name: el.textContent}
      bootData.forEach(row => {
        // row indexes
        // 0 positionKey,
        // 1 sequenceId,
        // 2 createdAt,
        // 3 userId,
        // 4 depth,
        // 5 descendantCount
        return itemsHash[row[0]] = {
          key: row[0],
          title: null,
          headings: [],
          sequenceId: row[1],
          createdAt: row[2],
          actorId: row[3],
          visible: false,
          depth: row[4],
          descendantCount: row[5],
          unread: this.loader.sequenceIdIsUnread(row[1]),
          poll: null,
          stance: null,
          visible: this.visibleKeys.includes(row[0])
        };
      });

      Records.events.collection.chain()
             .find({discussionId: this.discussion.id})
             .simplesort('positionKey')
             .data().forEach(event => {
        let poll;
        if (event.kind === "poll_created") {
          poll = event.model().poll();
          if (poll.discardedAt) { return; }
        }

        itemsHash[event.positionKey] = {
          key: event.positionKey,
          commentId: event.eventableType === 'Comment' ? event.eventableId : null,
          sequenceId: event.sequenceId,
          createdAt: event.createdAt,
          actorId: event.actorId,
          title: event.pinned ? (event.pinnedTitle || event.fillPinnedTitle()) : null,
          visible: false,
          unread: this.loader.sequenceIdIsUnread(event.sequenceId),
          headings: [],
          depth: event.depth,
          descendantCount: event.descendantCount,
          visible: this.visibleKeys.includes(event.positionKey),
          poll,
          stance: (poll && poll.myStance()) || null
        };
      });

      this.items = sortBy(Object.values(itemsHash), i => i.key);

      const createdEvent = this.discussion.createdEvent();
      this.items.unshift({
        key: createdEvent.positionKey,
        title: this.discussion.title,
        headings: [],
        sequenceId: 0,
        visible: this.visibleKeys.includes(createdEvent.positionKey),
        unread: false,
        event: createdEvent,
        poll: null,
        stance: null,
        depth: 1,
        descendantCount: 0
      });
    }
  },

  mounted() {
    EventBus.$on('toggleThreadNav', () => { return this.open = !this.open; });

    Records.events.fetch({
      params: {
        exclude_types: 'group discussion',
        discussion_id: this.discussion.id,
        pinned: true,
        per: 200
      }
    });

    let bootData = [];
    Records.events.remote.fetch({
      path: 'timeline',
      params: {
        topic_id: this.discussion.topicId
    }}).then(data => {
      bootData = data;
      return this.buildItems(bootData);
    });

    this.watchRecords({
      key: 'thread-nav'+this.discussion.id,
      collections: ["events", "discussions"],
      query: () => {
        if (bootData.length) { this.buildItems(bootData); }
      }
    });

    EventBus.$on('visibleKeys', keys => {
      this.visibleKeys = keys;
      this.items.forEach(item => {
        item.visible = this.visibleKeys.includes(item.key);
      });
    });
  }
};

</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.disable-select.thread-sidebar(v-if="discussion" v-model="open" :permanent="$vuetify.display.mdAndUp"  app fixed location="right" clipped color="background" floating)
  template(v-if="items.length > 1")
    v-list(nav density="compact" :lines="false")
      v-list-subheader(v-t="'strand_nav.jump_to'")
      v-list-item(color="info" :prepend-icon="mdiArrowUpThin" :title="$t('strand_nav.start')" @click="scrollToTop" :to="baseUrl+'/0'")
      v-list-item(color="info" :active="focusMode == 'unread'" :prepend-icon="mdiMessageBadgeOutline" :title="$t('strand_nav.unread')" @click="scrollToUnread" :to="baseUrl+'?unread'" v-if="loader.firstUnreadSequenceId()" exact)
      v-list-item(color="info" :active="focusMode == 'newest'" :prepend-icon="mdiLightningBolt" :title="$t('strand_nav.latest')" @click="scrollToNewest" :to="baseUrl+'?newest'" exact)
      //v-list-item(:prepend-icon="mdiPlus" :title="$t('strand_nav.add_comment')" @click="scrollToNewest" :to="baseUrl+'?newest'" exact)
      //v-list-item(:prepend-icon="mdiArrowDownThin" :title="$t('strand_nav.bottom')" @click="scrollToSequenceId(lastItemSequenceId())" :to="baseUrl+'/'+lastItemSequenceId()" exact)
      v-list-subheader(v-t="'strand_nav.timeline'")
    div.strand-nav__toc
      router-link.strand-nav__entry.text-caption(
        :class="{'strand-nav__entry--visible': item.visible, 'strand-nav__entry--selected': (item.sequenceId == selectedSequenceId || item.commentId == selectedCommentId), 'strand-nav__entry--unread': isSignedIn && item.unread}"
        :style="{'border-width': (item.depth * 2)+'px'}"
        v-for="item in items"
        :key="item.key"
        :to="baseUrl+'/'+item.sequenceId"
        @click="scrollToSequenceId(item.sequenceId)")
          .strand-nav__stance-icon-container(v-if="item.poll && item.poll.showResults()")
            poll-common-icon-panel.poll-proposal-chart-panel__chart.mr-1(:poll="item.poll" show-my-stance :size="18" :stanceSize="12")
          //span {{item.key}}
          span(v-if="item.title") {{item.title}}
</template>

<style lang="sass">
.strand-nav__stance-icon-container
  display: inline-block

.strand-nav__toc
  display: flex
  flex-direction: column
  min-height: 70%

.strand-nav__entry:empty
  flex-grow: 1

.strand-nav__entry
  display: block
  border-left: 2px solid #ccc
  padding-left: 8px
  padding-right: 8px
  margin-left: 8px
  min-height: 2px

.strand-nav__entry--unread
  border-color: var(--v-accent-lighten1)!important

.strand-nav__entry--selected
  border-color: var(--v-primary-darken1)!important
// .strand-nav__entry--visible
//   border-color: var(--v-primary-darken1)!important

.strand-nav__entry:hover
  border-color: var(--v-primary-darken1)!important

.strand-nav__entry:hover, .strand-nav__entry--visible
  background-color: #f8f8f8

.v-theme--dark, .v-theme--darkBlue
  .strand-nav__entry
    border-left: 2px solid #999
  .strand-nav__entry:hover, .strand-nav__entry--visible
    background-color: #222


</style>
