<style>
.poll-common-choose-type__poll-types {
  margin: 0;
  padding: 0;
}

.poll-common-choose-type__poll-type {
  list-style-type: none;
  height: 64px;
}

.poll-common-choose-type__poll-type-link {
  display: flex;
  cursor: pointer;
  text-decoration: none;
  &:hover { text-decoration: none; }
}

.poll-common-choose-type__poll-type-link i {
  padding: 10px 10px 10px 0;
}

.poll-common-choose-type__icon {
  margin-left: -16px;
}

.poll-common-choose-type__content {
  margin-left: 16px;
  line-height: 24px;
}
</style>

<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import EventBus  from '@/shared/services/event_bus'
import { iconFor } from '@/shared/helpers/poll'

export default
  props:
    poll: Object
  methods:
    iconForPollType: (pollType) ->
      iconFor { pollType: pollType } # :/

    choose: (type) ->
      # EventBus.$emit @, 'nextStep', type
  computed:
    pollTypes: -> AppConfig.pollTypes
</script>

<template>
  <div class="poll-common-choose-type__select-poll-type">
    <div :class="'poll-common-choose-type__poll-type--' + pollType" v-for="(pollType, index) in pollTypes()" :key="index">
      <v-list-item @click="choose(pollType)" class="poll-common-choose-type__poll-type">
        <i :class="'mdi mdi-24px poll-common-choose-type__icon ' + iconForPollType(pollType)"></i>
        <div :class="'poll-common-choose-type__content poll-common-choose-type__start-poll--' + pollType">
          <div v-t="'decision_tools_card.' + pollType + '_title'" class="poll-common-choose-type__poll-type-title md-subhead"></div>
          <div v-t="'poll_' + pollType + '_form.tool_tip_collapsed'" class="poll-common-choose-type__poll-type-subtitle md-caption"></div>
        </div>
      </v-list-item>
    </div>
  </div>
</template>
