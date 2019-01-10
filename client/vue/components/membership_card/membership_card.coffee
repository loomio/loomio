Records        = require 'shared/services/records'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'
RecordLoader   = require 'shared/services/record_loader'
I18n           = require 'shared/services/i18n'
Records        = require 'shared/services/records'

module.exports =
  props:
    group: Object
    pending: Boolean
  data: ->
    fragment: ''
    plusUser: Records.users.build(avatarKind: 'mdi-plus')
    fetched: false
    searchOpen: false
  created: ->
    if @pending
      @cardTitle = 'membership_card.invitations'
      @order = '-createdAt'
    else
      @cardTitle = "membership_card.#{@group.targetModel().constructor.singular}_members"
      @order = '-admin'

    @loader = new RecordLoader
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

  // TODO: fix template
  template:
    """
    <section
      aria-labelledby="membership-card-title"
      v-if="show()"
      :class="{'membership-card--pending': pending}"
      class="membership-card lmo-card lmo-no-print"
    >
      <div class="lmo-md-actions">
        <h2
          v-t="{ path: cardTitle, args: { values: } }"
          translate-values="{pollType: '{{group.targetModel().translatedPollType()}}'}" ng-if="!searchOpen" class="membership-card__title lmo-truncate lmo-card-heading lmo-flex__grow" id="membership-card-title"></h2>
        <md-button ng-click="toggleSearch()" ng-if="!searchOpen" class="md-button--tiny membership-card__search-button"><i class="mdi mdi-magnify"></i></md-button>
        <md-input-container ng-class="{'membership-card__search--open': searchOpen}" md-no-float="true" class="membership-card__search md-block md-no-errors">
            <input ng-model="fragment" ng-model-options="{debounce: 300}" ng-change="fetchMemberships()" placeholder="{{'memberships_page.fragment_placeholder' | translate}}" class="membership-card__filter">
            <md-button ng-if="searchOpen" ng-click="toggleSearch()" class="md-button--tiny"><i class="mdi mdi-close"></i></md-button>
        </md-input-container>
      </div>
      <plus_button ng-if="canAddMembers()" click="invite" message="membership_card.invite_to_{{group.targetModel().constructor.singular}}" class="membership-card__membership membership-card__invite"></plus_button>
      <div ng-repeat="membership in memberships() | orderBy: ['-admin', '-createdAt'] | limitTo: (loader.numRequested || 10) track by membership.id" data-username="{{membership.user().username}}" class="membership-card__membership lmo-flex lmo-flex__center">
          <user_avatar user="membership.user()" size="medium" coordinator="membership.admin" no-link="!membership.acceptedAt" class="lmo-margin-right"></user_avatar>
          <div layout="column" class="membership-card__user lmo-flex lmo-flex__grow lmo-truncate"> <span>{{membership.userName() || membership.user().email }}</span>
              <outlet name="after-membership-user" model="membership"></outlet>
              <div translate="user_page.online_field" translate-value-value="{{::membership.user().lastSeenAt | timeFromNowInWords}}" ng-if="::membership.user().lastSeenAt" class="membership-card__last-seen md-caption"></div>
              <div translate="user_page.invited" translate-value-value="{{::membership.user().createdAt | timeFromNowInWords}}" ng-if="!membership.acceptedAt" class="membership-card__last-seen md-caption"></div>
          </div>
          <membership_dropdown membership="membership"></membership_dropdown>
      </div>
      <loading ng-if="loader.loading"></loading>
      <div ng-if="showLoadMore()" class="lmo-md-actions">
          <md-button ng-if="showLoadMore()" ng-click="loader.loadMore()" translate="common.action.load_more" class="md-accent"></md-button><span>{{recordsDisplayed()}} / {{recordCount()}}</span></div>
    </section>
    """
