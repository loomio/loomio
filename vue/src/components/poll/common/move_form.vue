<script lang="coffee">
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import EventBus from '@/shared/services/event_bus'
import Flash  from '@/shared/services/flash'
import { onError } from '@/shared/helpers/form'
import { map, orderBy } from 'lodash'

export default
  props:
    poll: Object
    close: Function

  data: ->
    groupId: @poll.groupId
    groups: []

  mounted: ->
    parent = @poll.group().parentOrSelf()
    Records.groups.fetchByParent(parent).then =>
      adminGroups = [parent].concat(Records.groups.find(parentId: parent.id)).filter (group) =>
        group.adminsInclude(Session.user())

      sortedGroups = orderBy adminGroups, 'fullName'

      @groups = map adminGroups, (group) =>
        text: group.fullName
        value: group.id
        disabled: (group.id == @poll.groupId)

  methods:
    submit: ->
      @poll.setErrors({})
      @poll.groupId = @groupId
      @poll.save()
      .then (data) =>
        group = Records.groups.find(@groupId)
        Flash.success("poll_common_move_form.success", {poll_type: @poll.translatedPollType(), group: group.name})
        @close()
      .catch onError(@poll)

</script>
<template lang="pug">
v-card.poll-common-move-form(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value="poll.processing")
  v-card-title
    h1.headline(tabindex="-1" v-t="{path: 'poll_common_move_form.title', args: {poll_type: poll.translatedPollType() }}")
    v-spacer
    dismiss-modal-button(:close='close')
  v-card-text
    loading(v-if="!groups.length")
    v-select(v-if="groups.length" v-model="groupId" :items="groups" :label="$t('move_thread_form.body')")
  v-card-actions.poll-common-form-actions
    v-spacer
    v-btn.poll-common-form__submit(color="primary" @click='submit()' :loading="poll.processing")
      span(v-t="'common.action.move'")
</template>
