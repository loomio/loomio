<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';
import TopicService from '@/shared/services/topic_service';
import { sortBy, last, pickBy } from 'lodash-es';
import ScrollService from '@/shared/services/scroll_service';
import Session        from '@/shared/services/session';
import { mdiMessageBadgeOutline, mdiArrowUpThin, mdiArrowDownThin, mdiBellOutline, mdiBellOffOutline, mdiBellRingOutline } from '@mdi/js';

export default {
  mixins: [WatchRecords, UrlFor],
  props: {
    topic: Object,
    loader: Object,
    focusMode: String,
    focusSelector: String
  },

  data() {
    return {
      mdiMessageBadgeOutline,
      mdiArrowUpThin,
      mdiArrowDownThin,
      mdiBellOutline,
      mdiBellOffOutline,
      mdiBellRingOutline,
      open: null,
      pinnedItems: [],
      // items: [],
      // visibleKeys: [],
      baseUrl: '',
      topicActions: {}
    };
  },

  computed: {
    selectedSequenceId() { return parseInt(this.$route.params.sequence_id); },
    selectedCommentId() { return parseInt(this.$route.params.comment_id); },
    isSignedIn() { return Session.isSignedIn(); },
    memberActions() {
      return Object.values(pickBy(this.topicActions, a => a.name && a.collection === 'members' && a.canPerform()));
    },
    menuActions() {
      return Object.values(pickBy(this.topicActions, a => a.name && a.collection === 'actions' && a.canPerform()));
    }
  },

  methods: {
    lastItemSequenceId() {
      return this.items[this.items.length - 1].sequenceId;
    },

    scrollToNewest() {
      ScrollService.scrollTo(`.sequenceId-${this.topic.lastSequenceId()}`);
    },
    scrollToEnd() {
      ScrollService.scrollTo('#add-comment');
    },
    openVolumeForm() {
      EventBus.$emit('openModal', {
        component: 'ChangeVolumeForm',
        props: { model: this.topic }
      });
    },
    scrollToUnread() {
      ScrollService.scrollTo(`.sequenceId-${this.loader.firstUnreadSequenceId()}`);
    },
    scrollToTop() {
      ScrollService.scrollTo('.sequenceId-0');
    },
    scrollToBottom() {
      ScrollService.scrollTo(`.positionKey-${last(this.items).key}`);
    },

    scrollToSequenceId(id) {
      ScrollService.scrollTo(`.sequenceId-${id}`);
    }
  },

  mounted() {
    this.topicActions = TopicService.actions(this.topic);
    this.topic.fetchUsersNotifiedCount();
    this.baseUrl = this.urlFor(this.topic.topicable());
    EventBus.$on('toggleThreadNav', () => { return this.open = !this.open; });

    Records.events.fetch({
      params: {
        exclude_types: 'group discussion',
        topic_id: this.topic.id,
        pinned: true,
        per: 200
      }
    });

    this.watchRecords({
      key: 'thread-nav'+this.topic.id,
      collections: ["events", "discussions", "polls", "topics", "memberships"],
      query: () => {
        this.topicActions = TopicService.actions(this.topic);
        this.pinnedItems = Records.events.collection.chain()
          .find({topicId: this.topic.id, pinned: true})
          .simplesort('positionKey')
          .data()
          .filter(e => !e.model()?.discardedAt)
          .map(event => {
            const model = event.model();
            const isPoll = event.kind === 'poll_created';
            const poll = isPoll ? model.poll() : null;
            return {
              key: event.positionKey,
              sequenceId: event.sequenceId,
              title: (model && model.title) || event.pinnedTitle || event.fillPinnedTitle(),
              poll,
              user: !isPoll && event.actor() || null
            };
          });
      }
    });

    // let bootData = [];
    // Records.events.remote.fetch({
    //   path: 'timeline',
    //   params: {
    //     topic_id: this.topic.id
    // }}).then(data => {
    //   bootData = data;
    //   return this.buildItems(bootData);
    // });

    // EventBus.$on('visibleKeys', keys => {
    //   this.visibleKeys = keys;
    //   this.items.forEach(item => {
    //     item.visible = this.visibleKeys.includes(item.key);
    //   });
    // });
  }
};

</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.disable-select.thread-sidebar(v-if="topic" v-model="open" :permanent="$vuetify.display.mdAndUp"  app fixed location="right" clipped color="background" floating)
  v-list(nav density="compact" :lines="false")
    v-list-subheader(v-t="'strand_nav.jump_to'")
    v-list-item(color="info" :prepend-icon="mdiArrowUpThin" :title="$t('strand_nav.start')" @click="scrollToTop" :to="baseUrl+'/0'")
    v-list-item(v-for="item in pinnedItems" :key="item.key" :value="item.key" :title="item.title" @click="$router.push(baseUrl+'/'+item.sequenceId); scrollToSequenceId(item.sequenceId)")
      template(v-slot:prepend)
        poll-common-icon-panel(v-if="item.poll && item.poll.showResults()" :poll="item.poll" show-my-stance :size="24" :stanceSize="12")
        v-icon(v-else-if="item.user")
          user-avatar(:user="item.user" :size="24" no-link)
        v-icon(v-else) mdi-pin-outline
    v-list-item(color="info" :active="focusMode == 'unread'" :prepend-icon="mdiMessageBadgeOutline" :title="$t('strand_nav.unread') + ' (' + topic.unreadItemsCount() + ')'" @click="scrollToUnread" :to="baseUrl+'?unread'" v-if="loader.unreadRanges.length" exact)
    v-list-item(color="info" :prepend-icon="mdiArrowDownThin" :title="$t('strand_nav.end')" @click="scrollToEnd" :to="baseUrl+'/'+topic.lastSequenceId()")
  template(v-if="isSignedIn")

    v-list(nav density="compact" :lines="false")
      v-list-subheader(v-t="'strand_nav.notifications'")
      v-list-item(:prepend-icon="topic.readerVolume === 'loud' ? mdiBellRingOutline : topic.readerVolume === 'quiet' ? mdiBellOffOutline : mdiBellOutline" :title="$t(topic.readerVolume === 'loud' ? 'strand_nav.email_all_activity' : topic.readerVolume === 'quiet' ? 'strand_nav.email_none' : 'strand_nav.email_notifications')" @click="openVolumeForm")

    v-list(nav density="compact" :lines="false" v-if="memberActions.length")
      v-list-subheader(v-t="'membership_card.thread_members'")
      v-list-item(
        v-for="action in memberActions"
        :key="action.name"
        :title="$t(action.name, (action.nameArgs && action.nameArgs()) || {})"
        @click="action.perform()")
        template(v-slot:prepend)
          common-icon(:name="action.icon")

    v-list(nav density="compact" :lines="false" v-if="menuActions.length")
      v-list-subheader(v-t="'members_panel.header_actions'")
      v-list-item(
        v-for="action in menuActions"
        :key="action.name"
        :title="$t(action.name, (action.nameArgs && action.nameArgs()) || {})"
        @click="action.perform()")
        template(v-slot:prepend)
          common-icon(:name="action.icon")
  //v-list-subheader(v-t="'strand_nav.timeline'")
  //div.strand-nav__toc
  //  router-link.strand-nav__entry.text-caption(
  //    :class="{'strand-nav__entry--visible': item.visible, 'strand-nav__entry--selected': (item.sequenceId == selectedSequenceId || item.commentId == selectedCommentId), 'strand-nav__entry--unread': isSignedIn && item.unread}"
  //    :style="{'border-width': (item.depth * 2)+'px'}"
  //    v-for="item in items"
  //    :key="item.key"
  //    :to="baseUrl+'/'+item.sequenceId"
  //      .strand-nav__stance-icon-container(v-if="item.poll && item.poll.showResults()")
  //        poll-common-icon-panel.poll-proposal-chart-panel__chart.mr-1(:poll="item.poll" show-my-stance :size="18" :stanceSize="12")
  //      //span {{item.key}}
  //      span(v-if="item.title") {{item.title}}
</template>

<style lang="sass">
.thread-sidebar .v-list-item-title
  white-space: normal !important

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
