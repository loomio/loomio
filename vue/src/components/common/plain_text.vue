<script setup>
import { computed } from 'vue';
const { model, field } = defineProps({ model: Object, field: String });
const content = computed(() => model.translationId ? model.translation().fields[field] : model[field]);
</script>

<template lang="pug">
span.plain-text {{content}}
</template>
