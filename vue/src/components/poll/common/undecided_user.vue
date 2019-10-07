<style lang="css">
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

export default
  props:
    user: Object
    poll: Object
  data: ->
    remindExecuting: false
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
v-list-item.poll-common-undecided-user
  v-list-item-avatar
    user-avatar(:user='user', size='thirtysix')
  v-list-item-content
    v-list-item-title.poll-common-undecided-user__name {{ user.name || user.email }}
  v-list-item-action.poll-common-undecided-user__action(v-if='poll.isActive() && canAdministerPoll() && !remindExecuting')
    .poll-common-undecided-user--reminded(v-if='user.reminded')
      p.lmo-hint-text(v-t="'poll_common_undecided_user.reminded'")
    .poll-common-undecided-user--unreminded(v-if='!user.reminded')
      v-btn.poll-common-undecided-user__remind(color="accent" text @click='remind()', v-t="'common.action.remind'")
  loading(v-if='remindExecuting')

</template>
