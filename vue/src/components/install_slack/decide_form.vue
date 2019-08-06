<script lang="coffee">
import AppConfig from '@/shared/services/session'
import Records   from '@/shared/services/records'

import { applyPollStartSequence } from '@/shared/helpers/apply'

export default
  props:
    group: Object
  data: ->
    poll: Records.polls.build groupId: $scope.group.id
  methods:
  created: ->
    applyPollStartSequence @,
      afterSaveComplete: (event) ->
        @announcement = Records.announcements.buildFromModel(event)
</script>
<template lang="pug">
.install-slack-decide-form
  h2.lmo-h2(v-t="'install_slack.decide.heading'")
  p.lmo-hint-text(v-t="'install_slack.decide.helptext'", v-if='!poll.pollType')
  //- .poll-common-start-poll(ng-switch='currentStep')
  //-   poll_common_choose_type.animated(ng-switch-when='choose', poll='poll')
  //-   poll_common_directive.animated(ng-switch-when='save', poll='poll', name='form')
  //-   poll_common_form_actions.animated(ng-switch-when='save', poll='poll')
  //-   announcement_form.animated(ng-switch-when='announce', announcement='announcement')
  //- .lmo-flex.install-slack-form__actions(ng-switch='currentStep')
  //- v-btn(v-if="currentStep == \'choose\'", ng-click="$emit(\'$close\')", v-t="'install_slack.common.do_it_later'")
  //- v-btn(@click="$emit(\'$close\')", v-t="'install_slack.common.do_it_later'")
</template>
