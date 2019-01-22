<style lang="scss">
.user-page { margin-top: 16px; }
.user-page__groups { margin-top: 24px; }
.user-page__groups-title { margin: 0; }
.user-page__group { padding: 0 !important; }

.user-page__contact-user {
  margin: 8px 0;
  width: 100%;
}
</style>

<script lang="coffee">
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'
fromNow        = require 'vue/mixins/from_now'
urlFor         = require 'vue/mixins/url_for'

{ applyLoadingFunction } = require 'shared/helpers/apply'

_isEmpty     = require 'lodash/isempty'
_sortBy     = require 'lodash/sortby'

module.exports =
  mixins: [fromNow, urlFor]
  data: ->
    user: {}
  created: ->
    # applyLoadingFunction(@, 'loadGroupsFor')
    @setUser()
    Records.users.findOrFetchById(@$route.params.key).then @setUser, (error) ->
      # EventBus.broadcast $rootScope, 'pageError', error
  methods:
    setUser: ->
      return if @user
      if @user = (Records.users.find(@$route.params.key) or Records.users.find(username: @$route.params.key))[0]
        # EventBus.broadcast $rootScope, 'currentComponent', {title: @user.name, page: 'userPage'}
        @loadGroupsFor(@user)

    contactUser: ->
      ModalService.open 'ContactRequestModal', user: => @user

    loadGroupsFor: (user) ->
      Records.memberships.fetchByUser(user)
  computed:
    canContactUser: ->
      AbilityService.canContactUser(@user)

    isEmptyUser: ->
      _isEmpty @user

    orderedFormalGroups: ->
      _sortBy @user.formalGroups(), 'fullName'
</script>

<template>
  <div class="loading-wrapper container main-container lmo-one-column-layout">
    <loading v-if="isEmptyUser"></loading>
    <main v-if="!isEmptyUser" class="user-page main-container lmo-row">
      <div class="lmo-card user-page__profile">
        <div layout="row" class="user-page__content lmo-flex">
          <div class="user-page__avatar lmo-margin-right">
            <user-avatar :user="user" size="featured"></user-avatar>
            <v-btn v-if="canContactUser()" @click="contactUser()" v-t="{ path: 'user_page.contact_user', args: { name: user.firstName() } }" class="md-block md-primary md-raised user-page__contact-user"></v-btn>
          </div>
          <div class="user-page__info">
            <h1 class="lmo-h1">{{user.name}}</h1>
            <div class="lmo-hint-text">@{{user.username}}</div>
            <p>{{user.shortBio}}</p>
            <div v-t="{ path: 'user_page.locale_field', args: { value: user.localeName() } }" v-if="user.localeName()"></div>
            <div v-t="{ path: 'user_page.location_field', args: { value: user.location } }" v-if="user.location"></div>
            <div v-t="{ path: 'user_page.online_field', args: { value: fromNow(user.lastSeenAt) } }" v-if="user.lastSeenAt"></div>
            <div class="user-page__groups">
              <h3 v-t="'common.groups'" class="lmo-h3 user-page__groups-title"></h3>
              <v-list>
                <v-list-tile v-for="group in orderedFormalGroups" :key="group.id" class="user-page__group lmo-flex lmo-flex__center">
                  <img :src="group.logoUrl()" class="md-avatar lmo-box--small lmo-margin-right">
                  <a :href="urlFor(group)">{{group.fullName}}</a>
                </v-list-tile>
              </v-list>
              <!-- <loading v-if="loadGroupsForExecuting"></loading> -->
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>
