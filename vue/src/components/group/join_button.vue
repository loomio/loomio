<script lang="coffee">
import Session         from '@/shared/services/session'
import Records         from '@/shared/services/records'
import EventBus        from '@/shared/services/event_bus'
import AbilityService  from '@/shared/services/ability_service'
import Flash           from '@/shared/services/flash'

export default
  props:
    group:
      required: true
      type: Object

    block: Boolean

  data: ->
    membership: null
    hasRequestedMembership: false

  created: ->
    if !Session.user().membershipFor(@group)
      Records.membershipRequests.fetchMyPendingByGroup(@group.id)

      @watchRecords
        collections: ['memberships', "membershipRequests"]
        query: =>
          @hasRequestedMembership = @group.hasPendingMembershipRequestFrom(Session.user())
          @membership = Session.user().membershipFor(@group)

  methods:
    join: ->
      if Session.isSignedIn()
        if @canJoinGroup
          Records.memberships.joinGroup(@group).then =>
            EventBus.$emit 'joinedGroup', {group: @group}
            Flash.success('join_group_button.messages.joined_group', group: @group.fullName)
        else
          EventBus.$emit('openModal',
                          component: 'MembershipRequestForm',
                          props: { group: @group })
      else
        EventBus.$emit('openModal', component: 'AuthModal')

  computed:
    label: ->
      if @hasRequestedMembership
        'join_group_button.membership_requested'
      else
        'join_group_button.join_group'

    canJoinGroup: ->
      @group && AbilityService.canJoinGroup(@group)

    canRequestMembership: ->
      AbilityService.canRequestMembership(@group)

</script>

<template lang="pug">
v-alert(outlined color="primary" dense v-if="!membership && (canJoinGroup || canRequestMembership || hasRequestedMembership)")
  v-layout(align-center)
    span(v-t="'join_group_button.not_a_member'")
    v-spacer
    v-btn.join-group-button(color="primary" v-t="label" @click="join" :disabled="hasRequestedMembership")
</template>
