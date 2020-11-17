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
.strand-new-discussion.context-panel.lmo-action-dock-wrapper#context(:aria-label="$t('context_panel.aria_intro', {author: discussion.authorName(), group: discussion.group().fullName})" v-observe-visibility="{callback: viewed, once: true}")
  discussion-privacy-badge.mr-2(:discussion="discussion")
  strand-members.my-1(:discussion="discussion")
    //- v-spacer
    //- //- span(v-for="group in groups")
    //- //-   router-link(:to="group.to") {{group.text}}
    //- .lmo-badge.lmo-pointer(v-t="'common.privacy.closed'" v-if='discussion.closedAt')
    //-   v-tooltip(bottom) {{ exactDate(discussion.closedAt) }}
  //- strand-item-headline(:event="event" :eventable="discussion")
  strand-title.pt-2(:discussion="discussion")

  .mb-4
    router-link(:to="urlFor(discussion.author())" title="Thread author") {{discussion.authorName()}}
    mid-dot
    router-link.grey--text.body-2(:to='urlFor(discussion)')
      time-ago(:date='discussion.createdAt')
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
