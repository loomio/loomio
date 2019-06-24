<style lang="scss">
@import 'variables';
.poll-common-details-panel__started-by {
  // @include fontSmall;
  color: $grey-on-white;
}

.poll-common-details-panel__details {
  margin-top: 10px;
}
</style>

<script lang="coffee">
import Records        from '@/shared/services/records'
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import Flash   from '@/shared/services/flash'
import { listenForTranslations } from '@/shared/helpers/listen'
import PollModalMixin from '@/mixins/poll_modal'

export default
  mixins: [
    PollModalMixin
  ]
  props:
    poll: Object
  data: ->
    isAnnouncementModalOpen: false
    isRevisionHistoryModalOpen: false

  mounted: ->
    listenForTranslations(@)

  methods:
    openRevisionHistoryModal: ->
      @isRevisionHistoryModalOpen = true
    openAnnouncementModal: ->
      @isAnnouncementModalOpen = true
  created: ->
    @actions = [
      name: 'translate_poll'
      icon: 'mdi-translate'
      canPerform: => AbilityService.canTranslate(@poll)
      perform:    => @poll.translate(Session.user().locale)
    ,
      name: 'announce_poll'
      icon: 'mdi-account-plus'
      canPerform: => AbilityService.canAdministerPoll(@poll) and @poll.isActive()
      perform:    => ModalService.open 'AnnouncementModal', announcement: =>
        Records.announcements.buildFromModel(@poll)
    ,
      name: 'edit_poll'
      icon: 'mdi-pencil'
      canPerform: => AbilityService.canEditPoll(@poll)
      perform:    => @openEditPollModal(@poll)
    ,
      name: 'show_history'
      icon: 'mdi-history'
      canPerform: => @poll.edited()
      perform:    => ModalService.open 'RevisionHistoryModal', model: => @poll
    ]
</script>

<template lang="pug">
.poll-common-details-panel
  v-subheader(v-t="'poll_common.details'" v-if='poll.outcome()')
  .poll-common-details-panel__started-by
    span(v-t="{ path: 'poll_card.started_by', args: { name: poll.authorName() } }")
    span(aria-hidden='true') ·
    poll-common-closing-at(:poll='poll')
    span(v-if='poll.anonymous') ·
    span(v-if='poll.anonymous', md-colors="{color: 'primary-600', 'border-color': 'primary-600'}" v-t="'common.anonymous'")
  formatted-text.poll-common-details-panel__details(:model="poll" column="details")
  attachment-list(:attachments="poll.attachments")
  document-list(:model='poll')
  v-card-actions.lmo-md-actions
    reaction-display(:model="poll" :load="true")
    v-spacer
    action-dock(:model='poll' :actions='actions')
</template>
