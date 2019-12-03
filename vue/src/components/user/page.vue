<script lang="coffee">
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import UserModalMixin from '@/mixins/user_modal'

import { isEmpty }     from 'lodash'
import { approximate } from '@/shared/helpers/format_time'

export default
  mixins: [UserModalMixin]

  data: ->
    user: {}
    isMembershipsFetchingDone: false
    groups: []
    canContactUser: false
    loadingGroupsForExecuting: false

  created: ->
    @init()
    EventBus.$emit 'currentComponent', {page: 'userPage'}
    Records.users.findOrFetchById(@$route.params.key).then @init, (error) ->
      EventBus.$emit 'pageError', error

  methods:
    approximate: approximate
    init: ->
      if @user = (Records.users.find(@$route.params.key) or Records.users.find(username: @$route.params.key))[0]
        EventBus.$emit 'currentComponent', {title: @user.name, page: 'userPage'}
        @loadGroupsFor(@user)
        @watchRecords
          key: @user.id
          collections: ['groups', 'memberships']
          query: (store) =>
            @groups = @user.formalGroups()
            @canContactUser = AbilityService.canContactUser(@user)

    loadGroupsFor: (user) ->
      @loadingGroupsForExecuting = true
      Records.memberships.fetchByUser(user).then =>
        @loadingGroupsForExecuting = false

  computed:
    isEmptyUser: -> isEmpty @user

</script>

<template lang="pug">
v-content
  v-container.user-page.max-width-800.mt-4
    loading(v-if='isEmptyUser')
    div(v-else)
      v-card.user-page__profile
        v-card-title
          v-layout.align-center.justify-center
            h1.headline {{user.name}}
        v-card-text.user-page__content
          v-layout.user-page__info.mb-5.align-center.justify-center(column)
            user-avatar.mb-5(v-if="user.hasProfilePhoto()" :user='user', size='featured' :no-link="true")
            .lmo-hint-text @{{user.username}}
            formatted-text(v-if="user" :model="user" column="shortBio")
            div(v-t="{ path: 'user_page.locale_field', args: { value: user.localeName() } }", v-if='user.localeName()')
            span
              span(v-t="'common.time_zone'")
              span : {{user.timeZone}}
            div(v-t="{ path: 'user_page.location_field', args: { value: user.location } }", v-if='user.location')
            div(v-t="{ path: 'user_page.online_field', args: { value: approximate(user.lastSeenAt) } }", v-if='user.lastSeenAt')
            v-btn.my-4.user-page__contact-user(v-if="canContactUser" color="accent" outlined @click='openContactRequestModal(user)' v-t="{ path: 'user_page.contact_user', args: { name: user.firstName() } }")
      v-card.mt-4.user-page__groups
        v-card-text
          h3.lmo-h3.user-page__groups-title
            span {{user.firstName()}}
            span 's
            space
            span(v-t="'common.groups'")
          v-list(dense)
            v-list-item.user-page__group(v-for='group in groups' :key='group.id' :href='urlFor(group)')
              v-list-item-avatar
                v-avatar.mr-2(tile size="48")
                  img(:src='group.logoUrl()')
              v-list-item-title {{group.fullName}}
          loading(v-if='loadingGroupsForExecuting')
</template>
