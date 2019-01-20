<style lang="scss">
</style>

<script lang="coffee">
module.exports =
  props:
    group: Object
    setting: String
    translateValues: Boolean
  computed:
    translateKey: ->
      "group_form.#{_.snakeCase(@setting)}"
</script>

<template>
    <div class="group-setting-checkbox">
      <!-- <md-checkbox ng-model="group[setting]">
        <span translate="{{translateKey()}}" translate-values="translateValues"></span>
      </md-checkbox> -->
    </div>
</template>
