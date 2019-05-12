<style lang="scss">
.poll-common-votes-panel__stance {
  display: flex;
  align-items: flex-start;
  margin: 7px 0;
}

.poll-common-votes-panel__stance-content {
  margin-left: 10px;
}
</style>

<script lang="coffee">
import { listenForTranslations } from '@/shared/helpers/listen'
import { participantName }       from '@/shared/helpers/poll'

export default
  components:
    PollCommonDirective: -> import('@/components/poll/common/directive')
  props:
    stance: Object
  created: ->
    # listenForTranslations @
  computed:
    orderedStanceChoices: ->
      _.sortBy @stance.stanceChoices(), 'rank'

    participantName: -> participantName(@stance)
</script>

<template lang="pug">
.poll-common-votes-panel__stance
  user-avatar.lmo-flex__no-shrink(:user='stance.participant()', size='small')
  .poll-common-votes-panel__stance-content
    .poll-common-votes-panel__stance-name-and-option
      strong {{ participantName }}
      span.lmo-hint-text(v-t="'poll_common_votes_panel.none_of_the_above'", v-if='!stance.stanceChoices().length')
      poll-common-directive(name='stance-choice', :stance-choice='choice', v-if='choice.score > 0', v-for='choice in orderedStanceChoices', :key='choice.id')
    .poll-common-votes-panel__stance-reason(v-if='stance.reason')
      span.lmo-markdown-wrapper(v-if="!stance.translation && stance.reasonFormat == 'md'", v-marked='stance.reason')
      span.lmo-markdown-wrapper(v-if="!stance.translation && stance.reasonFormat == 'html'", v-html='stance.reason')
      translation(v-if='stance.translation', :model='stance', field='reason')
</template>
