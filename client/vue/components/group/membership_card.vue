<script lang="coffee">
Records        = require 'shared/services/records'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'
RecordLoader   = require 'shared/services/record_loader'
I18n           = require 'shared/services/i18n'
Records        = require 'shared/services/records'

fromNow        = require 'vue/mixins/from_now'

module.exports =
  mixins: [fromNow]
  props:
    group: Object
    pending: Boolean
  data: ->
    fragment: ''
    plusUser: Records.users.build(avatarKind: 'mdi-plus')
    fetched: false
    searchOpen: false
    loader: new RecordLoader
      collection: 'memberships'
      params:
        per: 20
        pending: @pending
        group_id: @group.id

  methods:
    show: ->
      return false if (@recordCount() == 0 && @pending)
      @initialFetch() if @canView()
      @canView()

    canView: ->
      if @pending
        AbilityService.canViewPendingMemberships(@group)
      else
        AbilityService.canViewMemberships(@group)

    recordCount: ->
      if @pending
        @group.pendingMembershipsCount
      else
        @group.membershipsCount - @group.pendingMembershipsCount

    toggleSearch: ->
      @fragment = ''
      @searchOpen = !@searchOpen
      @$nextTick => document.querySelector('.membership-card__search input').focus()

    showLoadMore: ->
      @loader.numRequested < @recordCount() && _.isEmpty @fragment && !@loader.loading

    canAddMembers: ->
      AbilityService.canAddMembers(@group.targetModel().group() || @group) && !@pending

    memberships: ->
      if !_.isEmpty @fragment
        _.filter @records(), (membership) =>
          _.includes membership.userName().toLowerCase(), @fragment.toLowerCase()
      else
        @records()

    orderedMemberships: ->
      limit = @loader.numRequested || 10
      _.slice(_.orderBy(@memberships(), ['-admin', '-createdAt']), 0, limit)

    recordsDisplayed: ->
      _.min [@loader.numRequested, @recordCount()]

    initialFetch: ->
      @loader.fetchRecords(per: 4) unless @fetched
      @fetched = true

    records: ->
      if @pending
        @group.pendingMemberships()
      else
        @group.activeMemberships()

    invite: ->
      ModalService.open 'AnnouncementModal', announcement: =>
        Records.announcements.buildFromModel(@group.targetModel())

    fetchMemberships: ->
      return unless !_.isEmpty @fragment
      Records.memberships.fetchByNameFragment(@fragment, @group.key)

    cardTitle: ->
      if @pending
        'membership_card.invitations'
      else
        "membership_card.#{@group.targetModel().constructor.singular}_members"

  computed:
    pollType: ->
      @group.targetModel().translatedPollType() if @group.targetModel().isA('poll')
</script>

<template>
    <v-card
      aria-labelledby="membership-card-title"
      v-if="show()"
      :class="{'membership-card--pending': pending}"
      class="membership-card lmo-no-print"
    >
      <v-card-text>
        <div class="lmo-md-actions">
          <h2
            v-t="{ path: cardTitle(), args: { values: { pollType: pollType } } }"
            v-if="!searchOpen"
            class="membership-card__title lmo-truncate lmo-card-heading lmo-flex__grow" id="membership-card-title"
          ></h2>
          <button @click="toggleSearch()" v-if="!searchOpen" class="md-button--tiny membership-card__search-button">
            <i class="mdi mdi-magnify"></i>
          </button>
          <!-- <md-input-container ng-class="{'membership-card__search--open': searchOpen}" md-no-float="true" class="membership-card__search md-block md-no-errors">
              <input ng-model="fragment" ng-model-options="{debounce: 300}" ng-change="fetchMemberships()" placeholder="{{'memberships_page.fragment_placeholder' | translate}}" class="membership-card__filter">
              <md-button ng-if="searchOpen" ng-click="toggleSearch()" class="md-button--tiny"><i class="mdi mdi-close"></i></md-button>
          </md-input-container> -->
        </div>
        <plus-button
          v-if="canAddMembers()"
          :click="invite"
          :message="'membership_card.invite_to_' + group.targetModel().constructor.singular"
          class="membership-card__membership membership-card__invite"
        ></plus-button>
        <div
          v-for="membership in orderedMemberships()"
          :key="membership.id"
          data-username="membership.user().username"
          class="membership-card__membership lmo-flex lmo-flex__center"
        >
            <user-avatar
              :user="membership.user()"
              size="medium"
              :coordinator="membership.admin"
              :no-link="!membership.acceptedAt"
              class="lmo-margin-right"
            ></user-avatar>
            <div layout="column" class="membership-card__user lmo-flex lmo-flex__grow lmo-truncate">
              <span>{{membership.userName() || membership.user().email }}</span>
              <!-- <outlet name="after-membership-user" model="membership"></outlet> -->
              <div
                v-if="membership.user().lastSeenAt"
                v-t="{ path: 'user_page.online_field', args: { value: fromNow(membership.user().lastSeenAt) } }"
                class="membership-card__last-seen md-caption"
              ></div>
              <div
                v-if="!membership.acceptedAt"
                v-t="{ path: 'user_page.invited', args: { value: fromNow(membership.user().createdAt) } }"
                class="membership-card__last-seen md-caption"
              ></div>
            </div>
            <!-- <membership_dropdown membership="membership"></membership_dropdown>-->
        </div>
        <loading v-if="loader.loading"></loading>
        <div v-if="showLoadMore()" class="lmo-md-actions">
          <button
            v-if="showLoadMore()"
            @click="loader.loadMore()"
            v-t="'common.action.load_more'"
            class="md-accent"
          ></button>
          <span>{{recordsDisplayed()}} / {{recordCount()}}</span>
        </div>
      </v-card-text>
    </v-card>
</template>

<style lang="scss">
@import 'app.scss';

.membership-card__membership {
  padding: 8px 0;
}

.membership-card__search {
  margin: 0;
  width: 0;
  visibility: hidden;
  transition: width 0.25s ease-in-out;
  &--open {
    visibility: visible;
    width: 100%;
  }

  .md-button--tiny {
    position: absolute;
    right: 0;
    top: 0;
    padding: 0;
    margin: 0;
  }
}

.membership-card__last-seen {
  color: $grey-on-white;
}

.membership-card__title {
  line-height: 36px;
}
</style>
