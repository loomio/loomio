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
    isMembershipsFetchingDone: false
    isModalOpen: false
  created: ->
    # applyLoadingFunction(@, 'loadGroupsFor')
    @setUser()
    Records.users.findOrFetchById(@$route.params.key).then @setUser, (error) ->
      # EventBus.broadcast $rootScope, 'pageError', error
  methods:
    setUser: ->
      # return if @user
      if @user = (Records.users.find(@$route.params.key) or Records.users.find(username: @$route.params.key))[0]
      # EventBus.broadcast $rootScope, 'currentComponent', {title: @user.name, page: 'userPage'}
        @loadGroupsFor(@user)

    openModal: ->
      @isModalOpen = true
      # ModalService.open 'ContactRequestModal', user: => @user

    closeModal: ->
      @isModalOpen = false

    loadGroupsFor: (user) ->
      Records.memberships.fetchByUser(user).then =>
        @isMembershipsFetchingDone = true
  computed:
    canContactUser: ->
      console.log 'isMembershipsFetchingDone', @isMembershipsFetchingDone
      AbilityService.canContactUser(@user)

    isEmptyUser: ->
      _isEmpty @user

    orderedFormalGroups: ->
      _sortBy @user.formalGroups(), 'fullName'
</script>

<template lang="pug">
.loading-wrapper.container.main-container.lmo-one-column-layout
  loading(v-if='isEmptyUser')
  main.user-page.main-container.lmo-row(v-if='!isEmptyUser')
    .lmo-card.user-page__profile
      .user-page__content.lmo-flex(layout='row')
        .user-page__avatar.lmo-margin-right
          user-avatar(:user='user', size='featured')
          v-btn.md-block.md-primary.md-raised.user-page__contact-user(v-if='canContactUser', @click='openModal()', v-t="{ path: 'user_page.contact_user', args: { name: user.firstName() } }")
          v-dialog(v-model="isModalOpen", lazy, persistent)
            contact-request-modal(:user="user", :close="closeModal")
        .user-page__info
          h1.lmo-h1 {{user.name}}
          .lmo-hint-text @{{user.username}}
          p {{user.shortBio}}
          div(v-t="{ path: 'user_page.locale_field', args: { value: user.localeName() } }", v-if='user.localeName()')
          div(v-t="{ path: 'user_page.location_field', args: { value: user.location } }", v-if='user.location')
          div(v-t="{ path: 'user_page.online_field', args: { value: fromNow(user.lastSeenAt) } }", v-if='user.lastSeenAt')
          .user-page__groups
            h3.lmo-h3.user-page__groups-title(v-t="'common.groups'")
            v-list
              v-list-tile.user-page__group.lmo-flex.lmo-flex__center(v-for='group in user.formalGroups()', :key='group.id')
                img.md-avatar.lmo-box--small.lmo-margin-right(:src='group.logoUrl()')
                router-link(:to='urlFor(group)') {{group.fullName}}
            // <loading v-if="loadGroupsForExecuting"></loading>
</template>
