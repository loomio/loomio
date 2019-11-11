<script lang="coffee">
import { participantName }       from '@/shared/helpers/poll'

export default
  components:
    PollCommonDirective: -> import('@/components/poll/common/directive')
  props:
    stance: Object

  computed:
    orderedStanceChoices: ->
      _.sortBy @stance.stanceChoices(), 'rank'

    participantName: -> participantName(@stance)
</script>

<template lang="pug">
.poll-common-votes-panel__stance
  v-list-item-avatar
    user-avatar.lmo-flex__no-shrink(:user='stance.participant()', size='thirtysix')
  .poll-common-votes-panel__stance-content
    .poll-common-votes-panel__stance-name-and-option
      v-layout(align-center)
        span.pr-2 {{ participantName }}
    poll-common-stance(:stance="stance")
        //- poll-common-directive(name='stance-choice', :stance-choice='choice', v-if='choice.score > 0', v-for='choice in orderedStanceChoices', :key='choice.id')
</template>
<style lang="sass">
.poll-common-votes-panel__stance
	display: flex
	align-items: flex-start
	margin: 7px 0

</style>
