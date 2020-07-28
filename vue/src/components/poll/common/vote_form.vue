<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Flash   from '@/shared/services/flash'
import { optionColors, optionImages } from '@/shared/helpers/poll'
import { onError } from '@/shared/helpers/form'

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
      collections: ['poll_options']
      query: (records) =>
        options = @stance.poll().pollOptions()
        @optionGroups = if options.length == 4
          [[options[0], options[1]], [options[2], options[3]]]
        else
          [options]

  methods:
    submit: ->
      actionName = if !@stance.castAt then 'created' else 'updated'
      @stance.stanceChoicesAttributes = [{poll_option_id: @selectedOptionId}]
      @stance.save()
      .then =>
        @stance.poll().clearStaleStances()
        Flash.success "poll_#{@stance.poll().pollType}_vote_form.stance_#{actionName}"
        EventBus.$emit "closeModal"
      .catch onError(@stance)

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
form.poll-common-vote-form(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value="stance.processing")
  span(v-if="debug") {{stance}}
  v-layout(wrap)
    v-layout.mb-4(justify-space-around v-for='(optionGroup, index) in optionGroups' :key="index")
      label.poll-common-vote-form__button.poll-proposal-vote-form__button.rounded-lg.pa-2(:class="classes(option)" v-for='option in optionGroup' :key='option.id')
        input(type="radio" v-model="selectedOptionId" :value="option.id" name="name" :aria-label="$t('poll_' + stance.poll().pollType + '_options.' + option.name)")
        v-layout(column align-center)
          v-avatar(size="52px")
            img(aria-hidden="true" :src="'/img/' + optionImages[option.name] + '.svg'")
          span(aria-hidden="true" v-t="'poll_' + stance.poll().pollType + '_options.' + option.name")
  poll-common-stance-reason(:stance='stance' v-if='stance')
  v-card-actions
    v-spacer
    v-btn.poll-common-vote-form__submit(color="primary" @click='submit()' v-t="'poll_common.submit_vote'" :disabled='!selectedOptionId')
</template>
<style lang="sass">

.poll-proposal-vote-form__button--not-selected
  opacity: 0.3 !important

.poll-proposal-vote-form__button
  cursor: pointer
  input[type=radio]
    position: absolute
    opacity: 0
    width: 0
    height: 0

</style>
