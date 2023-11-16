<script lang="js">
import ThreadService  from '@/shared/services/thread_service';
import { map, compact, pick, pickBy, omit } from 'lodash-es';
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

<template lang="pug">
.strand-new-discussion.context-panel#context(v-observe-visibility="{callback: viewed, once: true}")
  v-layout.ml-n2(align-center wrap)
    v-breadcrumbs.context-panel__breadcrumbs(:items="groups")
      template(v-slot:divider)
        v-icon mdi-chevron-right
    v-spacer
    tags-display(:tags="discussion.tags" :group="discussion.group()")
    v-chip(
      v-if="discussion.private"
      small outlined
      :title="$t('discussion_form.privacy_private')"
      )
      i.mdi.mdi-lock-outline.mr-1
      span(v-t="'common.privacy.private'")
    v-chip(
      v-if="!discussion.private"
      small outlined
      :title="$t('discussion_form.privacy_public')"
      )
      i.mdi.mdi-earth.mr-1
      span(v-t="'common.privacy.public'")

  strand-title(:discussion="discussion")

  .mb-4
    user-avatar.mr-2(:user='author', :size='36')
    router-link.text--secondary(:to="urlFor(author)") {{authorName}}
    mid-dot
    router-link.text--secondary(:to='urlFor(discussion)')
      time-ago(:date='discussion.createdAt')
    span(v-show='discussion.seenByCount > 0')
      mid-dot
      a.context-panel__seen_by_count(v-t="{ path: 'thread_context.seen_by_count', args: { count: discussion.seenByCount } }"  @click="openSeenByModal()")
    span(v-show='discussion.usersNotifiedCount != null')
      mid-dot
      a.context-panel__users_notified_count(v-t="{ path: 'thread_context.count_notified', args: { count: discussion.usersNotifiedCount} }"  @click="actions.notification_history.perform")
  template(v-if="!collapsed")
    formatted-text.context-panel__description(:model="discussion" column="description")
    link-previews(:model="discussion")
    document-list(:model='discussion')
    attachment-list(:attachments="discussion.attachments")
    action-dock.py-2(:model='discussion' :actions='dockActions' :menu-actions='menuActions')
  strand-actions-panel(v-if="discussion.newestFirst" :discussion="discussion")
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
