<script lang="coffee">
import AppConfig   from '@/shared/services/app_config'
import EventBus    from '@/shared/services/event_bus'

export default
  props:
    zone:
      type: String
      default: AppConfig.timeZone
  data: ->
    dzone: @zone
  methods:
    names: ->
      _.uniq(_.values(AppConfig.timeZones)).sort()
    selectChanged: ->
      EventBus.$emit @, 'timeZoneSelected', @dzone

</script>

<template>
    <div class="time-zone-select">
      <div class="time-zone-select__change">
        <select md-select placeholder="Choose Timezone" v-model="dzone" :style="{ 'min-width': '10em' }" @change="selectChanged()">
          <option md-option :value="name" v-for="name in names()">{{name}}</option>
        </select>
        <!-- <md-item-template>
          <span>{{name}}</span>
        </md-item-template> -->
      </div>
    </div>
</template>
