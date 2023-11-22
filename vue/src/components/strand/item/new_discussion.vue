<script lang="js">
import ThreadService  from '@/shared/services/thread_service';
import { omit, pickBy } from 'lodash-es';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import openModal      from '@/shared/helpers/open_modal';
import StrandActionsPanel from '@/components/strand/actions_panel';

export default {
  components: {
    StrandActionsPanel
  },
  props: {
    event: Object,
    eventable: Object,
    collapsed: Boolean
  },

  watch: {
    'eventable.newestFirst'() {
      this.actions = omit(ThreadService.actions(this.eventable, this), ['dismiss_thread']);
    }
  },

  data() {
    return {actions: omit(ThreadService.actions(this.eventable, this), ['dismiss_thread'])};
  },

  mounted() {
    this.eventable.fetchUsersNotifiedCount();
  },

  computed: {
    author() {
      return this.discussion.author();
    },

    authorName() {
      return this.discussion.authorName();
    },

    discussion() { return this.eventable; },

    group() {
      return this.discussion.group();
    },

    dockActions() {
      return pickBy(this.actions, v => v.dock);
    },

    menuActions() {
      return pickBy(this.actions, v => v.menu);
    },

    status() {
      if (this.discussion.pinned) { return 'pinned'; }
    },

    groups() {
      return this.discussion.group().parentsAndSelf().map(group => {
        return {
          text: group.name,
          disabled: false,
          to: this.urlFor(group)
        };
      });
    }
  },

  methods: {
    viewed(viewed) {
      if (viewed && Session.isSignedIn()) { this.discussion.markAsSeen(); }
    },

    openSeenByModal() {
      openModal({
        component: 'SeenByModal',
        props: {
          discussion: this.discussion
        }
      });
    }
  }
};

</script>

<template>

<div class="strand-new-discussion context-panel" id="context" v-observe-visibility="{callback: viewed, once: true}">
  <v-layout class="ml-n2" align-center="align-center" wrap="wrap">
    <v-breadcrumbs class="context-panel__breadcrumbs" :items="groups">
      <template v-slot:divider="v-slot:divider">
        <common-icon name="mdi-chevron-right"></common-icon>
      </template>
    </v-breadcrumbs>
    <v-spacer></v-spacer>
    <tags-display :tags="discussion.tags" :group="discussion.group()"></tags-display>
    <v-chip v-if="discussion.private" small="small" outlined="outlined" :title="$t('discussion_form.privacy_private')"><i class="mdi mdi-lock-outline mr-1"></i><span v-t="'common.privacy.private'"></span></v-chip>
    <v-chip v-if="!discussion.private" small="small" outlined="outlined" :title="$t('discussion_form.privacy_public')"><i class="mdi mdi-earth mr-1"></i><span v-t="'common.privacy.public'"></span></v-chip>
  </v-layout>
  <strand-title :discussion="discussion"></strand-title>
  <div class="mb-4">
    <user-avatar class="mr-2" :user="author" :size="36"></user-avatar>
    <router-link class="text--secondary" :to="urlFor(author)">{{authorName}}</router-link>
    <mid-dot></mid-dot>
    <router-link class="text--secondary" :to="urlFor(discussion)">
      <time-ago :date="discussion.createdAt"></time-ago>
    </router-link><span v-show="discussion.seenByCount > 0">
      <mid-dot></mid-dot><a class="context-panel__seen_by_count" v-t="{ path: 'thread_context.seen_by_count', args: { count: discussion.seenByCount } }" @click="openSeenByModal()"></a></span><span v-show="discussion.usersNotifiedCount != null">
      <mid-dot></mid-dot><a class="context-panel__users_notified_count" v-t="{ path: 'thread_context.count_notified', args: { count: discussion.usersNotifiedCount} }" @click="actions.notification_history.perform"></a></span>
  </div>
  <template v-if="!collapsed">
    <formatted-text class="context-panel__description" :model="discussion" column="description"></formatted-text>
    <link-previews :model="discussion"></link-previews>
    <document-list :model="discussion"></document-list>
    <attachment-list :attachments="discussion.attachments"></attachment-list>
    <action-dock class="py-2" :model="discussion" :actions="dockActions" :menu-actions="menuActions"></action-dock>
  </template>
  <strand-actions-panel v-if="discussion.newestFirst" :discussion="discussion"></strand-actions-panel>
</div>
</template>
<style lang="sass">
@import '@/css/variables'
.context-panel__heading-pin
  margin-left: 4px

.context-panel
  .v-breadcrumbs
    padding: 4px 10px 4px 10px
    // margin-left: 0;

.context-panel__discussion-privacy i
  position: relative
  font-size: 14px
  top: 2px

.context-panel__details
  color: $grey-on-white
  align-items: center

.context-panel__description
  > p:last-of-type
    margin-bottom: 24px

</style>
