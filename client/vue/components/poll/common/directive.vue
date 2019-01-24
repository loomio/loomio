<style lang="scss">
</style>

<script lang="coffee">
import PollProposalForm from 'vue/components/poll/proposal/form.vue'
module.exports =
  components:
    'poll-proposal-form': PollProposalForm
  props:
    poll: Object
    stance: Object
    outcome: Object
    stanceChoice: Object
    back: Object
    name: String
  methods:
    componentName: ->
      pollType = (@stance or @outcome or @stanceChoice or @poll).poll().pollType

      if @$options.components["poll-#{pollType}-#{@name}"]
        "poll-#{pollType}-#{@name}"
      else
        "poll-common-#{@name}"
</script>

<template>
    <component :is="componentName()" :poll='poll' :stance='stance' :stance-choice='stanceChoice' :outcome='outcome' :back='back'></component>
</template>
