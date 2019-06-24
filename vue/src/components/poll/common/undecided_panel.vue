<script lang="coffee">
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import RecordLoader   from '@/shared/services/record_loader'
import LmoUrlService  from '@/shared/services/lmo_url_service'

export default
  props:
    poll: Object
  data: ->
    showingUndecided: false
    loaders:
      memberships: new RecordLoader
        collection: if @poll.isActive() then 'memberships' else 'poll_did_not_votes'
        path:       if @poll.isActive() then 'undecided' else ''
        params:
          poll_id: @poll.key
  methods:
    canShowUndecided: ->
      !@showingUndecided and
      !@poll.anonymous and
      @poll.undecidedCount > 0

    canEditPoll: ->
      AbilityService.canEditPoll(@poll)

    showUndecided: ->
      @showingUndecided = true
      @loaders.memberships.fetchRecords()

    moreMembershipsToLoad: ->
      @loaders.memberships.numLoaded < @poll.undecidedCount

    loadMemberships: ->
      @loaders.memberships.loadMore()

</script>

<template lang="pug">
.poll-common-undecided-panel
  v-btn.poll-common-undecided-panel__button(color="accent" outlined v-if='canShowUndecided()', @click='showUndecided()', v-t="{ path: 'poll_common_undecided_panel.show_undecided', args: { count: poll.undecidedCount } }")
  .poll-common-undecided-panel__panel.poll-common-undecided-panel__users(v-if='showingUndecided')
    v-subheader(v-t="{ path: 'poll_common_undecided_panel.undecided_users', args: { count: poll.undecidedCount } }")
    poll-common-undecided-user(:user='user', :poll='poll', v-for='user in poll.undecided()', :key='user.id')
    p(v-if='!canEditPoll()')
      span.lmo-hint-text(v-if='poll.guestGroup().pendingInvitationsCount == 1', v-t="'poll_common_undecided_panel.invitation_count_singular'")
      span.lmo-hint-text(v-if='poll.guestGroup().pendingInvitationsCount > 1', v-t="{ path: 'poll_common_undecided_panel.invitation_count_plural', args: { count: poll.guestGroup().pendingInvitationsCount } }")
    div(v-if='moreMembershipsToLoad()')
      v-btn(color="accent" outlined v-t="'common.action.load_more'", aria-label='common.action.load_more', @click='loadMemberships()')
    // moreInvitationsToLoad does not exist?
    //
      <div v-if="!moreMembershipsToLoad() && moreInvitationsToLoad() && canEditPoll()">
      <button v-t="'poll_common_undecided_panel.show_invitations'" aria-label="common.action.load_more" @click="showUndecided()" class="md-accent poll-common-undecided-panel__show-invitations"></button>
      <button v-if="loaders.invitations.numLoaded > 0" v-t="'common.action.load_more'" aria-label="common.action.load_more" @click="loadInvitations()" class="md-accent"></button>
      </div>
</template>
