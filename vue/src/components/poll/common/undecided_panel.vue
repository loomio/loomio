<style lang="scss">
</style>

<script lang="coffee">
Records        = require 'shared/services/records'
AbilityService = require 'shared/services/ability_service'
RecordLoader   = require 'shared/services/record_loader'
LmoUrlService  = require 'shared/services/lmo_url_service'

module.exports =
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

<template>
    <div class="poll-common-undecided-panel">
      <button v-if="canShowUndecided()" @click="showUndecided()" v-t="{ path: 'poll_common_undecided_panel.show_undecided', args: { count: poll.undecidedCount } }" class="md-accent poll-common-undecided-panel__button"></button>
      <div v-if="showingUndecided" class="poll-common-undecided-panel__panel poll-common-undecided-panel__users">
        <h3 v-t="{ path: 'poll_common_undecided_panel.undecided_users', args: { count: poll.undecidedCount } }" class="lmo-card-subheading"></h3>
        <poll-common-undecided-user :user="user" :poll="poll" v-for="user in poll.undecided()" :key="user.id"></poll-common-undecided-user>
        <p v-if="!canEditPoll()">
          <span v-if="poll.guestGroup().pendingInvitationsCount == 1" v-t="'poll_common_undecided_panel.invitation_count_singular'" class="lmo-hint-text"></span>
          <span v-if="poll.guestGroup().pendingInvitationsCount > 1" v-t="{ path: 'poll_common_undecided_panel.invitation_count_plural', args: { count: poll.guestGroup().pendingInvitationsCount } }" class="lmo-hint-text"></span>
        </p>
        <div v-if="moreMembershipsToLoad()">
          <button v-t="'common.action.load_more'" aria-label="common.action.load_more" @click="loadMemberships()" class="md-accent"></button>
        </div>
        <!-- moreInvitationsToLoad does not exist? -->
        <!-- <div v-if="!moreMembershipsToLoad() && moreInvitationsToLoad() && canEditPoll()">
          <button v-t="'poll_common_undecided_panel.show_invitations'" aria-label="common.action.load_more" @click="showUndecided()" class="md-accent poll-common-undecided-panel__show-invitations"></button>
          <button v-if="loaders.invitations.numLoaded > 0" v-t="'common.action.load_more'" aria-label="common.action.load_more" @click="loadInvitations()" class="md-accent"></button>
        </div> -->
      </div>
    </div>
</template>
