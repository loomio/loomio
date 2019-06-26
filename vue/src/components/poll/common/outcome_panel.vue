<script lang="coffee">
import Records        from '@/shared/services/records'
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import { listenForTranslations } from '@/shared/helpers/listen'
import PollModalMixin from '@/mixins/poll_modal'

export default
  mixins: [PollModalMixin]
  data: ->
    actions: [
      name: 'react'
      canPerform: => AbilityService.canReactToPoll(@poll)
    ,
      name: 'announce_outcome'
      icon: 'mdi-account-plus'
      active:     => @poll.outcome().announcementsCount == 0
      canPerform: => AbilityService.canAdministerPoll(@poll)
      perform:    => ModalService.open 'AnnouncementModal', announcement: =>
        Records.announcements.buildFromModel(@poll.outcome())
    ,
      name: 'edit_outcome'
      icon: 'mdi-pencil'
      canPerform: => AbilityService.canSetPollOutcome(@poll)
      perform:    => @openPollOutcomeModal(@poll.outcome())
    ,
      name: 'translate_outcome'
      icon: 'mdi-translate'
      canPerform: => AbilityService.canTranslate(@poll.outcome())
      perform:    => @poll.outcome().translate(Session.user().locale)
    ]

  props:
    poll: Object

  mounted: ->
    listenForTranslations(@)

</script>

<template lang="pug">
div(v-if="poll.outcome()" class="poll-common-outcome-panel lmo-action-dock-wrapper")
  h3.lmo-card-subheading(v-t="'poll_common.outcome'")
  .poll-common-outcome-panel__authored-by.caption
    span(v-t="{ path: 'poll_common_outcome_panel.authored_by', args: { name: poll.outcome().authorName() } }")
    time-ago(:date="poll.outcome().createdAt")
  formatted-text(:model="poll.outcome()" column="statement")
  document-list(:model="poll.outcome()")
  .lmo-md-actions
    reaction-display(:model="poll.outcome()" :load="true")
    action-dock(:model="poll.outcome()" :actions="actions")
  </div>
</div>
</template>
