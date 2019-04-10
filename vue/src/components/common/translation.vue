<style lang="scss">
.translation__body {
  font-style: italic;
}

.lmo-h1 .translation__body p { margin: 0; }
</style>

<script lang="coffee">
module.exports =
  props:
    model: Object
    field: String
  computed:
    translated: ->
      @model.translation[@field]
</script>

<template>
    <div class="translation">
      <div v-marked="translated" class="translation__body"></div>
    </div>
</template>
