<style lang="scss">
@import 'variables';
$box-width:60px;

.poll-meeting-vote-form__checkbox--legend {
  margin-top:4px;
}

.poll-meeting-vote-form__helptext {
  color: $grey-on-white;
}

.poll-meeting-vote-form--box {
  border: 2px solid $card-background-color;
  min-width: $box-width;
  width: $box-width;
  line-height: normal;
  text-align: center;
  margin: 0px 8px;
  &.md-button { height: $box-width; }
  img { width: 32px; }
}
</style>

<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import WatchRecords from '@/mixins/watch_records'

import { submitOnEnter } from '@/shared/helpers/keyboard'
import { submitStance }  from '@/shared/helpers/form'
import { buttonStyle }   from '@/shared/helpers/style'

import _compact from 'lodash/compact'
import _map from 'lodash/map'
import _toPairs from 'lodash/toPairs'
import _fromPairs from 'lodash/fromPairs'
import _some from 'lodash/some'
import _sortBy from 'lodash/sortBy'

export default
  mixins: [WatchRecords]
  props:
    stance: Object
  data: ->
    pollOptions: []
    vars: {}
    zone: null
    stanceValuesMap: _fromPairs _map @stance.poll().pollOptions(), (option) =>
      stanceChoice = @stance.stanceChoices().find((sc) => sc.pollOptionId == option.id) or {}
      [option.id, stanceChoice.score or 0]
    canRespondMaybe: @stance.poll().customFields.can_respond_maybe
    stanceValues: if @stance.poll().customFields.can_respond_maybe then [2,1,0] else [2, 0]
  created: ->
    EventBus.$on 'timeZoneSelected', (e, zone) => @zone = zone
    @watchRecords
      collections: ['poll_options']
      query: (records) =>
        @pollOptions = @stance.poll().pollOptions()
    @submit = submitStance @, @stance,
      prepareFn: =>
        @$emit 'processing'
        @stance.id = null
        attrs = _compact _map(_toPairs(@stanceValuesMap), ([id, score]) ->
            {poll_option_id: id, score:score} if score > 0
        )

        @stance.stanceChoicesAttributes = attrs if _some(attrs)
  mounted: ->
    # submitOnEnter @, element: @$el
  methods:
    selectedColor: (option, score) ->
      buttonStyle(score == @stanceValuesMap[option.id])

    click: (optionId, score)->
      @stanceValuesMap[optionId] = score

    orderedPollOptions: ->
      _sortBy @pollOptions, 'name'

</script>

<template lang='pug'>
form.poll-meeting-vote-form(@submit.prevent='submit()')
  h3.lmo-card-subheading.lmo-flex__grow(v-t="'poll_meeting_vote_form.your_response'")
  ul.poll-common-vote-form__options(md-list='')
    li.lmo-flex--row.lmo-flex__horizontal-center.lmo-flex__center(md-list-item='')
      h3.lmo-h3.poll-meeting-vote-form--box(v-t="'poll_meeting_vote_form.can_attend'")
      h3.lmo-h3.poll-meeting-vote-form--box(v-t="'poll_meeting_vote_form.if_need_be'", v-if='canRespondMaybe')
      h3.lmo-h3.poll-meeting-vote-form--box(v-t="'poll_meeting_vote_form.unable'")
      time-zone-select.lmo-margin-left
    li.poll-common-vote-form__option.lmo-flex--row(md-list-item='', v-for='option in orderedPollOptions()', :key='option.id')
      v-btn.poll-meeting-vote-form--box(type='button', md-colors='selectedColor(option, i)', v-for='i in stanceValues', :key='i', @click='click(option.id, i)')
        img.poll-common-form__icon(src='/img/agree.svg', v-if='i == 2')
        img.poll-common-form__icon(src='/img/abstain.svg', v-if='i == 1')
        img.poll-common-form__icon(src='/img/disagree.svg', v-if='i == 0')
      poll-meeting-time.lmo-margin-left(:name='option.name', :zone='zone')
  validation-errors(:subject='stance', field='stanceChoices')
  poll-common-add-option-button(:poll='stance.poll()')
  poll-common-stance-reason(:stance='stance')
  .poll-common-form-actions.lmo-flex.lmo-flex__space-between
    poll-common-show-results-button(v-if='stance.isNew()')
    div(v-if='!stance.isNew()')
    v-btn.md-primary.md-raised.poll-common-vote-form__submit(type='submit', v-t="'poll_common.vote'", aria-label=" $t('poll_meeting_vote_form.vote')")
</template>
