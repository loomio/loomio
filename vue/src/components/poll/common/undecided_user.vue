<style lang="scss">
.poll-common-undecided-user__name {
  margin-left: 12px;
}

.poll-common-undecided-user {
  margin: 8px 0;
}

</style>

<script lang="coffee">
FlashService   = require 'shared/services/flash_service'
AbilityService = require 'shared/services/ability_service'

{ applyLoadingFunction } = require 'shared/helpers/apply'

module.exports =
  props:
    user: Object
    poll: Object
  created: ->
    applyLoadingFunction @, 'remind'
  methods:
    canAdministerPoll: ->
      AbilityService.canAdministerPoll(@poll)

    remind: ->
      @user.remind(@poll).then =>
        FlashService.success 'poll_common_undecided_user.reminder_sent'
</script>

<template>
    <div layout="row" class="poll-common-undecided-user lmo-flex lmo-flex__center">
      <user-avatar :user="user" size="small"></user-avatar>
      <span class="poll-common-undecided-user__name lmo-flex__grow">{{ user.name || user.email }}</span>
      <div v-if="poll.isActive() && canAdministerPoll() && !remindExecuting" class="poll-common-undecided-user__action">
        <div v-if="user.reminded" class="poll-common-undecided-user--reminded">
          <p v-t="'poll_common_undecided_user.reminded'" class="lmo-hint-text"></p>
        </div>
        <div v-if="!user.reminded" class="poll-common-undecided-user--unreminded">
          <button @click="remind()" v-t="'common.action.remind'" class="md-accent poll-common-undecided-user__remind"></button>
        </div>
      </div>
      <loading v-if="remindExecuting"></loading>
    </div>
</template>
