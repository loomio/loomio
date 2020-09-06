<script lang="coffee">
import ThreadService  from '@/shared/services/thread_service'
import { map, compact, pick } from 'lodash'
import EventBus from '@/shared/services/event_bus'
import openModal      from '@/shared/helpers/open_modal'

export default
  props:
    event: Object
    collapsed: Boolean

  data: ->
    actions: ThreadService.actions(@event.model(), @)

  computed:
    discussion: ->
      @event.model()

    arrangementAction: -> @actions['edit_arrangement']

    editThread: -> @actions['edit_thread']

    dockActions: ->
      pick @actions, ['react', 'add_comment', 'subscribe', 'unsubscribe', 'unignore', 'show_history', 'edit_thread', 'announce_thread']

    menuActions: ->
      pick @actions, ['edit_tags',  'notification_history', 'translate_thread', 'close_thread', 'reopen_thread', 'move_thread', 'discard_thread', 'export_thread']

    status: ->
      return 'pinned' if @discussion.pinned

    statusTitle: ->
      @$t("context_panel.thread_status.#{@status}")

    groups: ->
      map compact([@discussion.group().parent(), @discussion.group()]), (group) =>
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
.strand-new-discussion.context-panel.lmo-action-dock-wrapper#context(:aria-label="$t('context_panel.aria_intro', {author: discussion.authorName(), group: discussion.group().fullName})" v-observe-visibility="{callback: viewed, once: true}")
  .strand-item-headline.d-flex.align-center
    //- | context
    user-avatar.mr-2(:user="discussion.author()" size="36")
    router-link(:to="urlFor(discussion.author())" title="Thread author") {{discussion.authorName()}}
    v-spacer
    span(v-for="group in groups")
      | {{group.text}}
      mid-dot
    span(aria-label="Thread privacy")
      span.nowrap.context-panel__discussion-privacy.context-panel__discussion-privacy--private(v-show='discussion.private')
        i.mdi.mdi-lock-outline
        span(v-t="'common.privacy.private'")
      span.nowrap.context-panel__discussion-privacy.context-panel__discussion-privacy--public(v-show='!discussion.private')
        i.mdi.mdi-earth
        span(v-t="'common.privacy.public'")

    mid-dot
    span(v-show='discussion.seenByCount > 0')
      a.context-panel__seen_by_count(v-t="{ path: 'thread_context.seen_by_count', args: { count: discussion.seenByCount } }"  @click="openSeenByModal()")
    .lmo-badge.lmo-pointer(v-t="'common.privacy.closed'" v-if='discussion.closedAt')
      v-tooltip(bottom) {{ exactDate(discussion.closedAt) }}
  strand-title.pt-1(:discussion="discussion")
  template(v-if="!collapsed")
    formatted-text.context-panel__description(:model="discussion" column="description" aria-label="Discussion context")
    document-list(:model='discussion')
    attachment-list(:attachments="discussion.attachments")
    action-dock(:model='discussion' :actions='dockActions' :menu-actions='menuActions' fetch-reactions)
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
