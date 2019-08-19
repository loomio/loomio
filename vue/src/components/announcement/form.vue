<script lang="coffee">
import Records        from '@/shared/services/records'
import ModalService   from '@/shared/services/modal_service'
import EventBus       from '@/shared/services/event_bus'
import utils          from '@/shared/record_store/utils'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import AbilityService from '@/shared/services/ability_service'
import AppConfig      from '@/shared/services/app_config'
import Flash   from '@/shared/services/flash'
import { audiencesFor, audienceValuesFor } from '@/shared/helpers/announcement'
import {each , sortBy, includes, map, pull, uniq, throttle, debounce} from 'lodash'
import { submitForm } from '@/shared/helpers/form'


export default
  props:
    close: Function
    announcement:
      type: Object
      required: true

  data: ->
    query: ''
    recipients: []
    searchResults: []
    upgradeUrl: AppConfig.baseUrl + 'upgrade'
    invitationsRemaining: 1000
    showInvitationsRemaining: false
    subscriptionActive: true
    canInvite: true
    maxMembers: 0

  created: ->
    @searchResults = if @invitingToGroup then [] else @announcement.model.members()
    @maxMembers = @announcement.model.group().parentOrSelf().subscriptionMaxMembers || 0
    if @invitingToGroup
      @announcement.model.fetchToken()

    if @announcement.model.group()
      @invitationsRemaining =
        (@announcement.model.group().parentOrSelf().subscriptionMaxMembers || 0) -
        @announcement.model.group().parentOrSelf().orgMembershipsCount

      @showInvitationsRemaining =
        @invitingToGroup &&
        @announcement.model.group().parentOrSelf().subscriptionMaxMembers

      @subscriptionActive = @announcement.model.group().parentOrSelf().subscriptionActive

      @canInvite = @subscriptionActive && (!@announcement.model.group().parentOrSelf().subscriptionMaxMembers || @invitationsRemaining > 0)

  mounted: ->
    @submit = submitForm @, @announcement,
      prepareFn: =>
        @announcement.recipients = @recipients
      successCallback: (data) =>
        @announcement.membershipsCount = data.memberships.length
        EventBus.$emit('closeModal')
      flashSuccess: 'announcement.flash.success'
      flashOptions:
        count: => @announcement.membershipsCount

  methods:
    tooManyInvitations: ->
        @showInvitationsRemaining && (@invitationsRemaining < @recipients.length)

    audiences: -> audiencesFor(@announcement.model)

    audienceValues: -> audienceValuesFor(@announcement.model)

    search: throttle (query) ->
      Records.announcements.search(query, @announcement.model).then (data) =>
        if data && data.length == 1 && data[0].id == 'multiple'
          each map(data[0].emails, @buildRecipientFromEmail), @addRecipient
        else
          @searchResults = uniq @recipients.concat utils.parseJSONList(data)
    , 300
    , {trailing: true}

    buildRecipientFromEmail: (email) ->
      id: email
      name: email
      email: email
      emailHash: email
      avatarKind: 'mdi-email-outline'

    copied: (e) ->
      @$copyText(e.text, @$refs.copyContainer.$el)
      Flash.success('common.copied')

    remove: (item) ->
      index = @recipients.indexOf(item)
      if (index >= 0)
        @recipients.splice(index, 1)

    addRecipient: (recipient) ->
      return unless recipient
      return if includes(@recipients, recipient)
      @searchResults.unshift recipient
      @recipients.unshift recipient
      @query = ''

    loadAudience: (kind) ->
      Records.announcements.fetchAudience(@announcement.model, kind).then (data) =>
        each sortBy(utils.parseJSONList(data), (e) => e.name || e.email ), @addRecipient

    resetShareableLink: ->
      @announcement.model.resetToken().then =>
        Flash.success('invitation_form.shareable_link_reset')

  computed:
    canUpdateAnyoneCanParticipate: ->
      @announcement.model.isA('poll') &&
      AbilityService.canAdminister(@announcement.model)

    shareableLink: ->
      if @announcement.model.token
        LmoUrlService.shareableLink(@announcement.model)
      else
        @$t('common.action.loading')

    invitingToGroup: ->
      @announcement.model.isA('group')

  watch:
    query: (q) ->
      @search q if q && q.length > 2
</script>

<template lang="pug">
v-card
  submit-overlay(:value="announcement.processing")
  v-card-title
    h1.headline(v-t="'announcement.form.' + announcement.kind + '.title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    .announcement-form
      div(v-if="invitingToGroup && !canInvite")
        .announcement-form__invite
          p(v-if="invitationsRemaining < 1" v-html="$t('announcement.form.no_invitations_remaining', {upgradeUrl: upgradeUrl, maxMembers: maxMembers})")
          p(v-if="!subscriptionActive" v-html="$('discussion.subscription_canceled', {upgradeUrl: upgradeUrl})")

      div(v-if="!invitingToGroup || canInvite")
        .announcement-form__invite
          p.announcement-form__help(v-t="'announcement.form.' + announcement.kind + '.helptext'")
          v-list
            v-list-item.announcement-form__audience(v-for='audience in audiences()', :key='audience', @click='loadAudience(audience)')
              v-list-item-avatar
                v-icon mdi-account-multiple
              v-list-item-content
                span(v-t="{ path: 'announcement.audiences.' + audience, args: audienceValues() }")
          v-autocomplete.announcement-form__input(multiple chips return-object autofocus hide-no-data hide-selected v-model='recipients' @change="query= ''" :search-input.sync="query" item-text='name' item-value="id" item-avatar="avatar_url.large" :placeholder="$t('announcement.form.placeholder')" :items='searchResults')
            template(v-slot:selection='data')
              v-chip.chip--select-multi(:value='data.selected', close, @click:close='remove(data.item)')
                user-avatar.mr-1(:user="data.item" size="small" :no-link="true")
                span {{ data.item.name }}
            template(v-slot:item='data')
              v-list-item-avatar
                user-avatar(:user="data.item" size="small" :no-link="true")
              v-list-item-content.announcement-chip__content
                v-list-item-title(v-html='data.item.name')

        v-layout(v-if="showInvitationsRemaining")
          v-spacer
          p.caption(v-html="$t('announcement.form.invitations_remaining', {count: invitationsRemaining, upgradeUrl: upgradeUrl })")

  v-card-actions
    div(v-if="recipients.length")
      p(v-show="invitingToGroup && tooManyInvitations()" v-html="$t('announcement.form.too_many_invitations', {upgradeUrl: upgradeUrl})")
    v-spacer
    v-btn.announcement-form__submit(color="primary" :disabled="!recipients.length || (invitingToGroup && tooManyInvitations())" @click="submit()" v-t="'common.action.send'")
</template>

<style lang="css">
.announcement-form__checkbox {
  margin: 16px 0;
}

.announcement-form__list-item,
.announcement-form__invited {
  padding: 0 !important;
}

.announcement-form__invite {
  margin-bottom: 16px;
}

.announcement-form__shareable-link,
.announcement-form__help {
  margin: 8px 0;
}

.announcement-form__audience {
  height: 42px;
  min-height: 42px;
  margin-bottom: 8px;
  /* // color: $primary-text-color;
  i { opacity: 0.8; } */
}
</style>
