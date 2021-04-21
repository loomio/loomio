<script lang="coffee">
import ThreadService  from '@/shared/services/thread_service'
import { map, compact, pick } from 'lodash'
import EventBus from '@/shared/services/event_bus'
import openModal      from '@/shared/helpers/open_modal'

export default
  props:
    discussion: Object

  data: ->
    actions: ThreadService.actions(@discussion, @)

  mounted: ->
    @discussion.fetchUsersNotifiedCount()

  computed:
    arrangementAction: -> @actions['edit_arrangement']

    editThread: -> @actions['edit_thread']

    dockActions: ->
      pick @actions, ['react', 'translate_thread', 'add_comment', 'subscribe', 'unsubscribe', 'unignore', 'edit_thread', 'announce_thread']

    menuActions: ->
      pick @actions, ['show_history',  'notification_history', 'close_thread', 'reopen_thread', 'move_thread', 'discard_thread', 'export_thread']

    status: ->
      return 'pinned' if @discussion.pinned

    statusTitle: ->
      @$t("context_panel.thread_status.#{@status}")

    groups: ->
      if @discussion.groupId
        map @discussion.group().parentsAndSelf(), (group) =>
          text: group.name
          disabled: false
          to: @urlFor(group)
      else
        [{
          text: @$t('discussion_form.invite_only_thread')
          disabled: false
          to: '/threads/direct'
        }]

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
.context-panel.lmo-action-dock-wrapper#context(:aria-label="$t('context_panel.aria_intro', {author: discussion.authorName(), group: discussion.group().fullName})" v-observe-visibility="{callback: viewed, once: true}")
  v-layout(align-center mr-3 ml-2 pt-2 wrap)
    v-breadcrumbs.context-panel__breadcrumbs(aria-label="Group" :items="groups" divider=">")
    tags-display(:tags="discussion.tags()")
    span
    v-spacer
    span.grey--text.body-2
      time-ago(aria-label="Thread started" :date='discussion.createdAt')

  h1.display-1.context-panel__heading.px-3#sequence-0(tabindex="-1" v-observe-visibility="{callback: titleVisible}")
    i.mdi.mdi-pin.context-panel__heading-pin(v-if="status == 'pinned'")
    span(v-if='!discussion.translation.title') {{discussion.title}}
    span(v-if='discussion.translation.title')
      translation(:model='discussion', field='title')

  div.mx-3.mb-2
    .context-panel__details.my-2.body-2(align-center)
      user-avatar.mr-4(:user='discussion.author()', :size='40')
      span
        router-link(:to="urlFor(discussion.author())" title="Thread author") {{discussion.authorName()}}
        mid-dot
        span(aria-label="Thread privacy")
          span.nowrap.context-panel__discussion-privacy(v-show='discussion.private')
            i.mdi.mdi-lock-outline
            span.text--secondary(v-t="'common.privacy.private'")
          span.nowrap.context-panel__discussion-privacy(v-show='!discussion.private')
            i.mdi.mdi-earth
            span.text--secondary(v-t="'common.privacy.public'")
        span(v-show='discussion.seenByCount > 0')
          mid-dot
          a.context-panel__seen_by_count(v-t="{ path: 'thread_context.seen_by_count', args: { count: discussion.seenByCount } }"  @click="openSeenByModal()")
        span(v-show='discussion.usersNotifiedCount != null')
          mid-dot
          a.context-panel__users_notified_count(v-t="{ path: 'thread_context.count_notified', args: { count: discussion.usersNotifiedCount} }"  @click="actions.notification_history.perform")
        span.context-panel__fork-details(v-if='discussion.forkedEvent() && discussion.forkedEvent().discussion()')
          mid-dot
          span.text--secondary(v-t="'thread_context.forked_from'")
          router-link(:to='urlFor(discussion.forkedEvent())') {{discussion.forkedEvent().discussion().title}}
      .lmo-badge.lmo-pointer(v-t="'common.privacy.closed'" v-if='discussion.closedAt')
        v-tooltip(bottom) {{ exactDate(discussion.closedAt) }}
    formatted-text.context-panel__description(:model="discussion" column="description" aria-label="Discussion context")
    link-previews(:model='discussion')
    document-list(:model='discussion')
    attachment-list(:attachments="discussion.attachments")
    action-dock(:model='discussion' :actions='dockActions' :menu-actions='menuActions' fetch-reactions)
  v-divider
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
