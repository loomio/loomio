<script lang="js">
import ThreadService  from '@/shared/services/thread_service';
import { omit, pickBy } from 'lodash-es';
import Session from '@/shared/services/session';
import openModal      from '@/shared/helpers/open_modal';
import StrandActionsPanel from '@/components/strand/actions_panel';
import UrlFor from '@/mixins/url_for';

export default {
  mixins: [UrlFor],
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
    },
    'discussion.groupId': 'updateGroups'
  },

  data() {
    return {
      groups: [],
      actions: omit(ThreadService.actions(this.eventable, this), ['dismiss_thread'])
    };
  },

  mounted() {
    this.eventable.fetchUsersNotifiedCount();
    this.updateGroups();
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
  },

  methods: {
    updateGroups() {
      this.groups = this.discussion.group().parentsAndSelf().map(group => {
        return {
          title: group.name,
          disabled: false,
          to: group.id ? this.urlFor(group) : '/threads/direct'
        };
      });
    },
    viewed(viewed) {
      if (viewed && Session.isSignedIn()) { this.discussion.markAsSeen(); }
    },

    openSeenByModal() {
      openModal({
        component: 'SeenByModal',
        persistent: false,
        props: {
          discussion: this.discussion,
        }
      });
    }
  }
};

</script>

<template lang="pug">
.strand-new-discussion.context-panel#context(v-intersect.once="{handler: viewed}")
  .d-flex.ml-n3.text-body-2
    v-breadcrumbs.context-panel__breadcrumbs(color="anchor" :items="groups")
      template(v-slot:divider)
        common-icon(name="mdi-chevron-right")
    v-spacer
    tags-display(:tags="discussion.tags" :group="discussion.group()")

  strand-title(:discussion="discussion")

  .mb-4.text-body-2
    user-avatar.mr-2(:user='author')
    router-link.text-medium-emphasis(:to="urlFor(author)") {{authorName}}
    mid-dot
    router-link.text-medium-emphasis(:to='urlFor(discussion)')
      time-ago(:date='discussion.createdAt')
    span.text-medium-emphasis(v-show='discussion.seenByCount > 0')
      mid-dot
      a.context-panel__seen_by_count.underline-on-hover(v-t="{ path: 'thread_context.seen_by_count', args: { count: discussion.seenByCount } }"  @click="openSeenByModal()")
    span.text-medium-emphasis(v-show='discussion.usersNotifiedCount != null')
      mid-dot
      a.context-panel__users_notified_count.underline-on-hover(v-t="{ path: 'thread_context.count_notified', args: { count: discussion.usersNotifiedCount} }"  @click="actions.notification_history.perform")

  template(v-if="!collapsed")
    formatted-text.context-panel__description(:model="discussion" column="description")
    link-previews(:model="discussion")
    document-list(:model='discussion')
    attachment-list(:attachments="discussion.attachments")
    action-dock.py-2(:model='discussion' :actions='dockActions' :menu-actions='menuActions')
  strand-actions-panel(v-if="discussion.newestFirst" :discussion="discussion")
</template>
<style lang="sass">
abbr[title]
  text-decoration: none
a
  cursor: pointer

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

.context-panel__description
  > p:last-of-type
    margin-bottom: 24px

</style>
