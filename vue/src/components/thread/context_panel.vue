<script lang="coffee">
import ThreadService  from '@/shared/services/thread_service'
import { exact }      from '@/shared/helpers/format_time'
import { listenForTranslations } from '@/shared/helpers/listen'
import { map, compact, pick } from 'lodash'
import EventBus from '@/shared/services/event_bus'

export default
  props:
    discussion: Object

  mounted: ->
    listenForTranslations(@)

  data: ->
    actions: ThreadService.actions(@discussion, @)

  computed:
    dockActions: ->
      pick ThreadService.actions(@discussion, @), ['react', 'add_comment', 'edit_thread', "announce_thread"]

    menuActions: ->
      pick ThreadService.actions(@discussion, @), [ "edit_tags", 'show_history', 'translate_thread', 'pin_thread', 'unpin_thread', 'close_thread', 'reopen_thread', 'move_thread', 'delete_thread']

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
    exact: exact
    titleVisible: (visible) ->
      EventBus.$emit('content-title-visible', visible)

    viewed: (viewed) ->
      @discussion.markAsSeen() if viewed

</script>

<template lang="pug">
.context-panel.lmo-action-dock-wrapper#context(v-observe-visibility="{callback: viewed, once: true}")
  v-layout(align-center mr-3 ml-2 pt-2 wrap)
    v-breadcrumbs(:items="groups" divider=">")
    tags-display(:discussion="discussion")
    span
    v-spacer
    span.grey--text.body-2
      time-ago(:date='discussion.createdAt')

  h1.display-1.context-panel__heading.px-3#sequence-0(v-observe-visibility="{callback: titleVisible}")
    span(v-if='!discussion.translation.title') {{discussion.title}}
    span(v-if='discussion.translation.title')
      translation(:model='discussion', field='title')
    i.mdi.mdi-pin.context-panel__heading-pin(v-if="status == 'pinned'")

  .mx-4
    .context-panel__details.my-2.body-2(align-center)
      user-avatar.mr-4(:user='discussion.author()', :size='40')
      span
        router-link(:to="urlFor(discussion.author())") {{discussion.authorName()}}
        mid-dot
        span.nowrap.context-panel__discussion-privacy.context-panel__discussion-privacy--private(v-show='discussion.private')
          i.mdi.mdi-lock-outline
          span(v-t="'common.privacy.private'")
        span.nowrap.context-panel__discussion-privacy.context-panel__discussion-privacy--public(v-show='!discussion.private')
          i.mdi.mdi-earth
          span(v-t="'common.privacy.public'")
        span(v-show='discussion.seenByCount > 0')
          mid-dot
          span.context-panel__seen_by_count(v-t="{ path: 'thread_context.seen_by_count', args: { count: discussion.seenByCount } }")
        span.context-panel__fork-details(v-if='discussion.forkedEvent() && discussion.forkedEvent().discussion()')
          mid-dot
          span(v-t="'thread_context.forked_from'")
          router-link(:to='urlFor(discussion.forkedEvent())') {{discussion.forkedEvent().discussion().title}}
      .lmo-badge.lmo-pointer(v-t="'common.privacy.closed'" v-if='discussion.closedAt')
        v-tooltip(bottom) {{ exact(discussion.closedAt) }}
    formatted-text.context-panel__description(:model="discussion" column="description")
    document-list(:model='discussion' skip-fetch)
    attachment-list(:attachments="discussion.attachments")
    v-layout.my-2(align-center)
      reaction-display.mb-2(:model="discussion" fetch)
      action-dock(:model='discussion' :actions='dockActions')
      action-menu.context-panel-dropdown(:model='discussion' :actions='menuActions')
  v-divider
</template>
<style lang="sass">
@import 'variables'
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
