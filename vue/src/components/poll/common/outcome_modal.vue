<script lang="coffee">
import Records from '@/shared/services/records'
import { fieldFromTemplate } from '@/shared/helpers/poll'
import Flash from '@/shared/services/flash'
import EventBus from '@/shared/services/event_bus'
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'

import Vue     from 'vue'
import { exact } from '@/shared/helpers/format_time'
import { parseISO } from 'date-fns'
import { uniq, map, sortBy, head, find, filter, sum } from 'lodash'
import { onError } from '@/shared/helpers/form'

import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'
import RecipientsAutocompleteMixin from '@/mixins/recipients_autocomplete_mixin'

export default
  mixins: [RecipientsAutocompleteMixin]

  components:
    RecipientsAutocomplete: RecipientsAutocomplete

  props:
    outcome: Object
    close: Function

  data: ->
    options: []
    bestOption: null
    clone: null
    isDisabled: false
    searchResults: []
    query: ''
    recipients: []
    groups: []
    users: []


  created: ->
    @clone = @outcome.clone()

    if @datesAsOptions()
      @options = map @clone.poll().pollOptions(), (option) ->
        id:        option.id
        value:     exact(parseISO(option.name))
        attendees: option.stances().length

      @bestOption = head sortBy @options, (option) ->
        -1 * option.attendees # sort descending, so the best option is first

      Vue.set(@clone, 'calendarInvite', true)

      @clone.pollOptionId = @outcome.pollOptionId or @bestOption.id
      @clone.customFields.event_summary = @clone.customFields.event_summary or @clone.poll().title

  mounted: ->
    @fetchMemberships()
    @watchRecords
      collections: ['groups', 'memberships']
      query: (records) => @updateSuggestions()

  methods:
    findUsers: ->
      chain = Records.users.collection.chain()

      if @clone.groupId
        chain = chain.find(id: {$in: @clone.group().memberIds()})

      chain = chain.find(id: {$nin: [Session.user().id]})

      if @query
        chain = chain.find
          $or: [
            {name: {'$regex': ["^#{@query}", "i"]}}
            {username: {'$regex': ["^#{@query}", "i"]}}
            {name: {'$regex': [" #{@query}", "i"]}}
          ]

      chain.data()

    updateSuggestions: ->
      @users = @findUsers()

    submit: ->
      @clone.customFields.should_send_calendar_invite = @clone.calendarInvite
      @clone.customFields.event_description = @clone.statement if @datesAsOptions()

      if @clone.isNew()
        actionName = "created"
      else
        actionName = "updated"

      @clone.save()
      .then (data) =>
        Flash.success("poll_common_outcome_form.outcome_#{actionName}")
        @closeModal()

      .catch onError(@clone)

    datesAsOptions: ->
      fieldFromTemplate @clone.poll().pollType, 'dates_as_options'

    newRecipients: (val) ->
      @recipients = val
      @clone.recipientAudience = (val.find((i) -> i.type=='audience') || {}).id
      @clone.recipientUserIds = map filter(val, (o) -> o.type == 'user'), 'id'
      @clone.recipientEmails = map filter(val, (o) -> o.type == 'email'), 'name'

  computed:
    model: -> @clone
    audiences: ->
      ret = []
      if @recipients.length == 0
        if @clone.group()
          ret.push
            id: 'group'
            name: @clone.group().name
            size: @clone.group().acceptedMembershipsCount
        if @clone.poll().discussionId
          ret.push
            id: 'discussion_group'
            name: @$t('announcement.audiences.discussion_group')
            size: @clone.poll().discussion().membersCount
        if @clone.poll().stancesCount > 1
          ret.push
            id: 'voters'
            name: @$t('announcement.audiences.voters', pollType: @clone.poll().translatedPollType())
            size: @clone.poll().stancesCount
        if @clone.poll().participantsCount > 1
          ret.push
            id: 'participants'
            name: @$t('announcement.audiences.participants')
            size: @clone.poll().participantsCount

      ret.filter (a) => a.name.match(new RegExp(@query, 'i'))

</script>

<template lang="pug">
v-card.poll-common-outcome-modal(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value='clone.processing')
  v-card-title
    h1.headline
      span(v-if='clone.isNew()' v-t="'poll_common_outcome_form.new_title'")
      span(v-if='!clone.isNew()' v-t="'poll_common_outcome_form.update_title'")
    v-spacer
    dismiss-modal-button(:close="close")
  .poll-common-outcome-form.px-4
    p Wrap up the process by entering and outcome and notiyfing people about it (fixme)
    //- p outcome.pollId {{outcome.pollId}}
    p audience: {{clone.recipientAudience}}
    p userIds: {{clone.recipientUserIds}}
    p userEmails: {{clone.recipientEmails}}
    //- p audiences: {{audiences}}
    //- p {{recipients.length}}
    recipients-autocomplete(
      :label="$t('action_dock.notify')"
      :placeholder="$t('poll_common_outcome_form.who_to_notify')"
      :users="users"
      :audiences="audiences"
      @new-query="newQuery"
      @new-recipients="newRecipients")

    .caption.outcome-modal__number-notified(v-if="notificationsCount != 1" v-t="{ path: 'poll_common_notify_group.members_count', args: { count: notificationsCount } }")
    .caption.outcome-modal__number-notified(v-else v-t="'discussion_form.one_person_notified'")

    .poll-common-calendar-invite(v-if='datesAsOptions()')
      .poll-common-calendar-invite__checkbox.poll-common-checkbox-option
        v-checkbox(v-model='clone.calendarInvite' :label="$t('poll_common_calendar_invite.calendar_invite')")
      .poll-common-calendar-invite__form(v-if='clone.calendarInvite')
        .poll-common-calendar-invite--pad-top
          v-select.lmo-flex__grow(v-model='clone.pollOptionId' :items="options" item-value="id" item-text="value" :label="$t('poll_common_calendar_invite.poll_option_id')")
        .poll-common-calendar-invite--pad-top
          v-text-field.poll-common-calendar-invite__summary(type='text' :placeholder="$t('poll_common_calendar_invite.event_summary_placeholder')" v-model='clone.customFields.event_summary' :label="$t('poll_common_calendar_invite.event_summary')")
          validation-errors(:subject='clone', field='event_summary')
          v-text-field.poll-common-calendar-invite__location(type='text' :placeholder="$t('poll_common_calendar_invite.location_placeholder')" v-model='clone.customFields.event_location' :label="$t('poll_common_calendar_invite.location')")
          //- v-textarea.md-input.poll-common-calendar-invite__description(type='text' :placeholder="$t('poll_common_calendar_invite.event_description_placeholder')" v-model='clone.customFields.event_description' :label="$t('poll_common_calendar_invite.event_description')")

    lmo-textarea.poll-common-outcome-form__statement.lmo-primary-form-input(:model='clone' field='statement' :label="$t('poll_common.statement')" :placeholder="$t('poll_common_outcome_form.statement_placeholder')")
      template(v-slot:actions)
        v-btn.poll-common-outcome-form__submit(color="primary" @click='submit()' v-t="'common.action.save'")
    validation-errors(:subject="clone" field="statement")
</template>
