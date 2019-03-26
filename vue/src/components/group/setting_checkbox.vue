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
      <v-checkbox v-model="group[setting]">
        <span v-t="{ path: translateKey, args: translateValues }"></span>
      </v-checkbox>
    </div>
</template>
