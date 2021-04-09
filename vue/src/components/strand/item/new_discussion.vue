<script lang="coffee">
import ThreadService  from '@/shared/services/thread_service'
import { map, compact, pick } from 'lodash'
import EventBus from '@/shared/services/event_bus'
import openModal      from '@/shared/helpers/open_modal'
import DiscussionPrivacyBadge from '@/components/discussion/privacy_badge'

export default
  props:
    event: Object
    collapsed: Boolean

  data: ->
    actions: ThreadService.actions(@event.model(), @)

  mounted: ->
    @event.model().fetchUsersNotifiedCount()

  computed:
    discussion: ->
      @event.model()

    arrangementAction: -> @actions['edit_arrangement']

    editThread: -> @actions['edit_thread']

    dockActions: ->
      pick @actions, ['react', 'translate_thread', 'add_comment', 'subscribe', 'unsubscribe', 'unignore', 'edit_thread', 'announce_thread']

    menuActions: ->
      pick @actions, ['show_history', 'notification_history', 'close_thread', 'reopen_thread', 'move_thread', 'discard_thread', 'export_thread']

    status: ->
      return 'pinned' if @discussion.pinned

    statusTitle: ->
      @$t("context_panel.thread_status.#{@status}")

    groups: ->
      @discussion.group().parentsAndSelf().map (group) =>
        text: group.name
        disabled: false
        to: @urlFor(group)

  methods:
    viewed: (viewed) ->
      @discussion.markAsSeen() if viewed

    openArrangementForm: -> @actions['edit_arrangement'].perform()

    openSeenByModal: ->
      openModal
        component: 'SeenByModal'
        props:
          discussion: @discussion

</script>

<template lang="pug">
.strand-new-discussion.context-panel#context(:aria-label="$t('context_panel.aria_intro', {author: discussion.authorName(), group: discussion.group().fullName})" v-observe-visibility="{callback: viewed, once: true}")
  v-layout.ml-n2(align-center wrap)
    v-breadcrumbs.context-panel__breadcrumbs(:items="groups" divider=">")
    tags-display(:tags="discussion.tags()")
    v-spacer
    span
      span.nowrap(v-show='discussion.private')
        i.mdi.mdi-lock-outline
        span.text--secondary(v-t="'common.privacy.private'")
      span.nowrap(v-show='!discussion.private')
        i.mdi.mdi-earth
        span.text--secondary(v-t="'common.privacy.public'")

  strand-title(:discussion="discussion")

  .mb-4
    router-link(:to="urlFor(discussion.author())" title="Thread author") {{discussion.authorName()}}
    mid-dot
    router-link.grey--text.body-2(:to='urlFor(discussion)')
      time-ago(:date='discussion.createdAt')
    span(v-show='discussion.seenByCount > 0')
      mid-dot
      a.context-panel__seen_by_count(v-t="{ path: 'thread_context.seen_by_count', args: { count: discussion.seenByCount } }"  @click="openSeenByModal()")
    span(v-show='discussion.usersNotifiedCount != null')
      mid-dot
      a.context-panel__users_notified_count(v-t="{ path: 'thread_context.count_notified', args: { count: discussion.usersNotifiedCount} }"  @click="actions.notification_history.perform")
  template(v-if="!collapsed")
    formatted-text.context-panel__description(:model="discussion" column="description")
    document-list(:model='discussion')
    attachment-list(:attachments="discussion.attachments")
    action-dock.py-2(:model='discussion' :actions='dockActions' :menu-actions='menuActions' fetch-reactions)
</template>
<style lang="sass">
@import '@/css/variables'
.context-panel__heading-pin
  margin-left: 4px

.context-panel
  .v-breadcrumbs
    padding: 0px 10px
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
