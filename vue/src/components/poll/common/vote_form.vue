<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Flash   from '@/shared/services/flash'
import Records   from '@/shared/services/records'
import { optionColors, optionImages } from '@/shared/helpers/poll'
import { isEqual, map } from 'lodash'

export default
  props:
    stance: Object
  data: ->
    selectedOptionId: @stance.pollOptionId()
    optionColors: optionColors()
    optionImages: optionImages()
    debug: @$route.query.debug
    optionGroups: []
  created: ->
    @watchRecords
      collections: ['pollOptions']
      query: (records) =>
        if @stance.poll().optionsDiffer(@pollOptions)
          options = @stance.poll().pollOptions()
          @optionGroups = if options.length == 4
            [[options[0], options[1]], [options[2], options[3]]]
          else
            [options]
            
  watch:
    selectedOptionId: ->
      EventBus.$emit('focusEditor')
      
  computed:
    poll: -> @stance.poll()
    selectedOption: -> Records.pollOptions.find(@selectedOptionId)

  methods:
    submit: ->
      actionName = if !@stance.castAt then 'created' else 'updated'
      @stance.stanceChoicesAttributes = [{poll_option_id: @selectedOptionId}]
      @stance.save()
      .then =>
        Flash.success "poll_#{@stance.poll().pollType}_vote_form.stance_#{actionName}"
        EventBus.$emit "closeModal"
      .catch => true

    isSelected: (option) ->
      @selectedOptionId == option.id

    classes: (option) ->
      if @selectedOptionId
        if @selectedOptionId == option.id
          ['elevation-5']
        else
          ['poll-proposal-vote-form__button--not-selected', 'elevation-1']
      else
        ['elevation-1']

</script>

<template lang="pug">
form.poll-common-vote-form(
  @keyup.ctrl.enter="submit()"
  @keydown.meta.enter.stop.capture="submit()"
)
  submit-overlay(:value="stance.processing")
  //- span(v-if="debug") {{stance}}
  v-layout(wrap)
    v-layout.mb-4(
      v-for='(optionGroup, index) in optionGroups'
      :key="index"
      justify-space-around
    )
      label.poll-common-vote-form__button.poll-proposal-vote-form__button.rounded-lg.pa-2(
        v-for='option in optionGroup'
        :key='option.id'
        :class="classes(option)"
      )
        input(
          v-model="selectedOptionId"
          :value="option.id"
          :aria-label="$t('poll_' + stance.poll().pollType + '_options.' + option.name)"
          type="radio"
          name="name"
        )
        v-layout(column align-center)
          v-avatar(size="52px")
            img(
              aria-hidden="true"
              :src="'/img/' + option.icon + '.svg'"
            )
          span(
            v-if="poll.pollOptionNameFormat == 'i18n'"
            v-t="'poll_' + stance.poll().pollType + '_options.' + option.name"
            aria-hidden="true"
          )
          span(
            v-if="poll.pollOptionNameFormat == 'plain'"
            aria-hidden="true"
          ) {{option.name}}
  p.text--secondary(v-if="selectedOption") {{selectedOption.name}}: {{selectedOption.meaning}}
  poll-common-stance-reason(:stance='stance' v-if='stance && selectedOptionId' :prompt="selectedOption.prompt")
  v-btn.poll-common-vote-form__submit(
    @click='submit()'
    :loading="stance.processing"
    :disabled='stance.saveDisabled || !selectedOptionId'
    color="primary"
    block
  )
    span(v-t="stance.castAt? 'poll_common.update_vote' : 'poll_common.submit_vote'")
</template>

<style lang="sass">
.poll-proposal-vote-form__button--not-selected
  opacity: 0.3 !important

.poll-proposal-vote-form__button
  border: 1px solid #eee
  cursor: pointer
  input[type=radio]
    position: absolute
    opacity: 0
    width: 0
    height: 0
  &:hover
    border: 1px solid var(--v-primary-base)
</style>
