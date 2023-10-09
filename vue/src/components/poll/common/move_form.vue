<script lang="coffee">
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import EventBus from '@/shared/services/event_bus'
import Flash  from '@/shared/services/flash'
import { map, orderBy } from 'lodash'

export default
  props:
    poll: Object
    close: Function

  data: ->
    groupId: @poll.groupId
    groups: []

  mounted: ->
    @groups = Session.user().groups().filter((g) => AbilityService.canStartPoll(g)).map (g) =>
      text: g.fullName
      value: g.id
      disabled: (g.id == @poll.groupId)

  methods:
    submit: ->
      @poll.groupId = @groupId
      @poll.save().then =>
        Flash.success("poll_common_move_form.success", {poll_type: @poll.translatedPollType(), group: @poll.group().fullName})
        @close()

</script>
<template lang="pug">
v-card.poll-common-move-form(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value="poll.processing")
  v-card-title
    h1.headline(tabindex="-1" v-t="{path: 'poll_common_move_form.title', args: {poll_type: poll.translatedPollType() }}")
    v-spacer
    dismiss-modal-button
  v-card-text
    loading(v-if="!groups.length")
    v-select(v-if="groups.length" v-model="groupId" :items="groups" :label="$t('move_thread_form.body')")
  v-card-actions.poll-common-form-actions
    v-spacer
    v-btn.poll-common-form__submit(color="primary" @click='submit()' :loading="poll.processing")
      span(v-t="'common.action.move'")
</template>
