<style lang="scss">
.poll-common-undecided-user__name {
  margin-left: 12px;
}

.poll-common-undecided-user {
  margin: 8px 0;
}

</style>

<script lang="coffee">
import Flash   from '@/shared/services/flash'
import AbilityService from '@/shared/services/ability_service'
import { applyLoadingFunction } from '@/shared/helpers/apply'

export default
  props:
    user: Object
    poll: Object
  data: ->
    remindExecuting: false
  # created: ->
  #   applyLoadingFunction @, 'remind'
  methods:
    canAdministerPoll: ->
      AbilityService.canAdministerPoll(@poll)

    remind: ->
      @remindExecuting = true
      @user.remind(@poll).then =>
        @remindExecuting = false
        Flash.success 'poll_common_undecided_user.reminder_sent'
</script>

<template lang="pug">
.poll-common-undecided-user.lmo-flex.lmo-flex__center(layout='row')
  user-avatar(:user='user', size='small')
  span.poll-common-undecided-user__name.lmo-flex__grow {{ user.name || user.email }}
  .poll-common-undecided-user__action(v-if='poll.isActive() && canAdministerPoll() && !remindExecuting')
    .poll-common-undecided-user--reminded(v-if='user.reminded')
      p.lmo-hint-text(v-t="'poll_common_undecided_user.reminded'")
    .poll-common-undecided-user--unreminded(v-if='!user.reminded')
      button.md-accent.poll-common-undecided-user__remind(@click='remind()', v-t="'common.action.remind'")
  loading(v-if='remindExecuting')

</template>
