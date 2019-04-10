<style lang="scss">
</style>
<script lang="coffee">
Session        = require 'shared/services/session'
AbilityService = require 'shared/services/ability_service'
EventBus       = require 'shared/services/event_bus'

{ registerKeyEvent }  = require 'shared/helpers/keyboard'
{ fieldFromTemplate } = require 'shared/helpers/poll'

_pull = require 'lodash/pull'
_includes = require 'lodash/includes'
_clone = require 'lodash/clone'

module.exports =
  props:
    poll: Object
  data: ->
    existingOptions: _clone @poll.pollOptionNames
    datesAsOptions: fieldFromTemplate(@poll.pollType, 'dates_as_options')
  created: ->
    # registerKeyEvent $scope, 'pressedEnter', $scope.poll.addOption, (active) ->
    #   active.classList.contains('poll-poll-form__add-option-input')
  methods:
    removeOption: (name) ->
      _pull(@poll.pollOptionNames, name)
      @poll.setMinimumStanceChoices()

    canRemoveOption: (name) ->
      _includes(@existingOptions, name) || AbilityService.canRemovePollOptions(@poll)
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
    v-list-tile(v-if="!poll.pollOptionNames.length")
      p.lmo-hint-text(v-if="datesAsOptions", v-t="{ path: 'poll_meeting_form.no_options', args: { zone: currentZone } }")
      p.lmo-hint-text(v-if='!datesAsOptions', v-t="'poll_common_form.no_options'")
    v-list-tile.poll-common-form__list-item(v-for='name in poll.pollOptionNames' :key="name")
      span.poll-poll-form__option-text(v-if="!datesAsOptions") {{name}}
      poll-meeting-time.poll-meeting-form__option-text.lmo-flex__grow(v-if='datesAsOptions', :name='name', :zone='zone')
      v-btn.poll-poll-form__option-button(v-if="canRemoveOption(name)", @click="removeOption(name)")
        i.mdi.mdi-close.mdi-24px.poll-poll-form__option-icon
    //- poll_meeting_time_field(v-if='datesAsOptions', poll='poll')
    v-list-tile.poll-common-form__add-option(v-if='!datesAsOptions', flex='true', layout='row')
      .poll-poll-form__add-option-field
        v-text-field.poll-poll-form__add-option-input(v-model='poll.newOptionName', type='text', :placeholder="$t('poll_common_form.options_placeholder')")
      div
        v-btn.poll-poll-form__option-button(@click='poll.addOption()')
          i.mdi.mdi-plus.mdi-24px.poll-poll-form__option-icon.poll-poll-form__option-icon--add
</template>
