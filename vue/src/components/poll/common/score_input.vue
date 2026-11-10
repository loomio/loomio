<script setup>
const value = defineModel({required: true});
const { label, minimum = 0, maximum } = defineProps({
  label: {type: String, required: true},
  minimum: Number,
  maximum: Number
});
</script>

<template>
  <v-text-field
    v-model.number="value"
    class="poll-common-score-input"
    :aria-label="label"
    type="number"
    :min="minimum"
    :max="maximum"
    :step="1"
    variant="outlined"
    density="compact"
    hide-details
    hide-spin-buttons
  />
</template>

<style>
.poll-common-score-input {
  flex: 0 0 6rem;
  width: 6rem;
}
.poll-common-score-input input {
  text-align: center;
}
</style>
