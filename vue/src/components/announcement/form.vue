<style lang="scss">
@import 'variables';
.announcement-form__checkbox {
  margin: 16px 0;
}

.announcement-form__list-item,
.announcement-form__invited {
  padding: 0 !important;
}

.announcement-form__copy {
  margin-bottom: 8px;
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
  color: $primary-text-color;
  i { opacity: 0.8; }
}
</style>

<script lang="coffee">
import Records        from '@/shared/services/records'
import ModalService   from '@/shared/services/modal_service'
import EventBus       from '@/shared/services/event_bus'
import utils          from '@/shared/record_store/utils'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import AbilityService from '@/shared/services/ability_service'
import Flash   from '@/shared/services/flash'
import { audiencesFor, audienceValuesFor } from '@/shared/helpers/announcement'
import {each , sortBy, includes, map, pull, uniq} from 'lodash'

export default {
  props:
    announcement: Object

  data: ->
    dannouncement: @announcement # does dannouncement get 'reset' when new announcement props?
    shareableLink: LmoUrlService.shareableLink(@announcement.model)
    selected: null
    query: ''
    recipients: []
    searchResults: @announcement.model.members()

  created: ->
    if @announcement.model.isA('group')
      @announcement.model.fetchToken().then =>
        @shareableLink = LmoUrlService.shareableLink(@announcement.model)
    # EventBus.listen $scope, 'removeRecipient', (_event, recipient) ->
    #   _pull $scope.announcement.recipients, recipient

  methods:
    audiences: -> audiencesFor(@announcement.model)
    audienceValues: -> audienceValuesFor(@announcement.model)
    search: (query) ->
      Records.announcements.search(query, @announcement.model).then (data) =>
        if data.length == 1 and data[0].id == 'multiple'
          each map(data[0].emails, @buildRecipientFromEmail), @addRecipient
        else
          @searchResults = uniq @searchResults.concat utils.parseJSONList(data)

    buildRecipientFromEmail: (email) ->
      id: email
      name: email
      email: email
      emailHash: email
      avatarKind: 'mdi-email-outline'

    copied: ->
      Flash.success('common.copied')

    remove: (item) ->
      index = this.recipients.indexOf(item.id)
      if (index >= 0)
        @recipients.splice(index, 1)

    addRecipient: (recipient) ->
      return unless recipient
      return if includes(@recipients, recipient.id)
      @searchResults.unshift recipient
      @recipients.unshift recipient.id
      @query = ''

    loadAudience: (kind) ->
      Records.announcements.fetchAudience(@announcement.model, kind).then (data) =>
        each sortBy(utils.parseJSONList(data), (e) => e.name || e.email ), @addRecipient

  computed:
    canUpdateAnyoneCanParticipate: ->
      @announcement.model.isA('poll') &&
      AbilityService.canAdminister(@announcement.model)

  watch:
    query: (q) ->
      @search q if q && q.length > 2
}
</script>

<template lang="pug">
v-card
  v-card-title
    h1.lmo-h1(v-t="'announcement.form.' + announcement.kind + '.title'")
    dismiss-modal-button
  v-card-text
    .announcement-form
      .announcement-form__invite
        p.announcement-form__help.md-subhead(v-t="'announcement.form.' + announcement.kind + '.helptext'")
        v-list
          v-list-tile.announcement-form__audience.md-whiteframe-1dp(v-for='audience in audiences()', :key='audience', @click='loadAudience(audience)')
            i.mdi.mdi-18px.mdi-account-multiple.lmo-margin-right--small
            span.md-body-1(v-t="{ path: 'announcement.audiences.' + audience, args: audienceValues() }")
          //- span recipients: {{recipients}}
          //- span results: {{serachResults}}
          v-autocomplete(multiple chips v-model='recipients' @change="query= ''" autofocus :search-input.sync="query" item-text='name' item-value="id" item-avatar="avatar_url.large" :placeholder="$t('announcement.form.placeholder')" :items='searchResults')
            template(v-slot:selection='data')
              v-chip.chip--select-multi(:selected='data.selected', close, @input='remove(data.item)')
                user-avatar(:user="data.item" size="small" :no-link="true")
                span {{ data.item.name }}
            template(v-slot:item='data')
              v-list-tile-avatar
                user-avatar(:user="data.item" size="small" :no-link="true")
              v-list-tile-content
                v-list-tile-title(v-html='data.item.name')
        //- v-list.announcement-form__invited
        //-   .md-subhead.announcement-form__num-notified
        //-     p.lmo-text-right(v-if='announcement.recipients.length == 0', v-t="'announcement.form.notified_empty'")
        //-     p.lmo-text-right(v-if='announcement.recipients.length == 1', v-t="'announcement.form.notified_singular'")
        //-     p.lmo-text-right(v-else='', v-t="{ path: 'announcement.form.notified', args: { notified: announcement.recipients.length } }")
        //-   v-list-tile.announcement-form__list-item(v-for='recipient in announcement.recipients', :key='recipient.emailHash')
        //-     // <announcement_chip user="recipient" show-close="true"></announcement_chip>
      .announcement-form__share-link(v-if="!announcement.model.isA('discussion') && announcement.recipients.length == 0")
        p.announcement-form__help.md-subhead(v-if="announcement.model.isA('group')", v-t="'invitation_form.shareable_link'")
        .announcement-shareable-link__content.lmo-flex--column
          .lmo-flex--row.lmo-flex__center(v-if='canUpdateAnyoneCanParticipate || announcement.model.anyoneCanParticipate')
            v-checkbox.announcement-form__checkbox(v-model='announcement.model.anyoneCanParticipate', @change='announcement.model.save()', v-if='canUpdateAnyoneCanParticipate')
              label(v-t="'announcement.form.anyone_can_participate'")
          .lmo-flex--row.lmo-flex__center(v-if="announcement.model.anyoneCanParticipate || announcement.model.isA('group')")
            .lmo-flex__grow.md-no-errors.announcement-form__shareable-link
              input(:value='shareableLink', :disabled='true')
            v-btn.md-accent.md-button--tiny.announcement-form__copy(title="$t('common.copy')", clipboard='true', text='shareableLink', on-copied='copied()')
              span(v-t="'common.copy'")
  v-card-actions
</template>
