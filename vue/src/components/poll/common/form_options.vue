<style lang="scss">
</style>
<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import EventBus       from '@/shared/services/event_bus'
import { fieldFromTemplate } from '@/shared/helpers/poll'
import _pull from 'lodash/pull'
import _includes from 'lodash/includes'
import _clone from 'lodash/clone'

export default
  props:
    poll: Object
  data: ->
    newOptionName: ''
    existingOptions: _clone @poll.pollOptionNames
    datesAsOptions: fieldFromTemplate(@poll.pollType, 'dates_as_options')
  methods:
    removeOption: (name) ->
      _pull(@poll.pollOptionNames, name)
      @poll.setMinimumStanceChoices()

    canRemoveOption: (name) ->
      _includes(@existingOptions, name) || AbilityService.canRemovePollOptions(@poll)

    addOption: ->
      @poll.newOptionName = @newOptionName
      @newOptionName = ''
      @poll.addOption()
  computed:
    currentZone: ->
      Session.user().timeZone

</script>
<template lang="pug">
.poll-common-form-options
  label.poll-common-form__options-label.md-caption(v-if='!datesAsOptions', v-t="'poll_common_form.options'")
  .poll-meeting-form__label-and-timezone(v-if="datesAsOptions")
    label.nowrap.poll-common-form__options-label.md-caption.lmo-flex__grow(v-t="'poll_meeting_form.timeslots'")
  v-list.md-block.poll-common-form__options
    validation-errors(:subject='poll', field='pollOptions')
    v-list-item(v-if="!poll.pollOptionNames.length")
      p.lmo-hint-text(v-if="datesAsOptions", v-t="{ path: 'poll_meeting_form.no_options', args: { zone: currentZone } }")
      p.lmo-hint-text(v-if='!datesAsOptions', v-t="'poll_common_form.no_options'")
    v-list-item.poll-common-form__list-item(v-for='name in poll.pollOptionNames' :key="name")
      span.poll-poll-form__option-text(v-if="!datesAsOptions") {{name}}
      poll-meeting-time.poll-meeting-form__option-text.lmo-flex__grow(v-if='datesAsOptions', :name='name', :zone='currentZone')
      v-btn.poll-poll-form__option-button(v-if="canRemoveOption(name)", @click="removeOption(name)")
        v-icon.mdi-24px.poll-poll-form__option-icon mdi-close
    poll-meeting-time-field(v-if='datesAsOptions', :poll='poll')
    v-list-item.poll-common-form__add-option(v-if='!datesAsOptions', flex='true', layout='row')
      .poll-poll-form__add-option-field
        v-text-field.poll-poll-form__add-option-input(v-model='newOptionName', type='text', :placeholder="$t('poll_common_form.options_placeholder')")
      div
        v-btn.poll-poll-form__option-button(@click='addOption()')
          i.mdi.mdi-plus.mdi-24px.poll-poll-form__option-icon.poll-poll-form__option-icon--add
</template>
