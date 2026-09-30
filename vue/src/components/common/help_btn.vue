<script setup lang="js">
import { useI18n } from 'vue-i18n';
import { manualUrl } from '@/shared/helpers/manual_url';

const { path, label } = defineProps({
  path: String,
  label: {
    type: String,
    default: 'common.user_guide'
  }
});
const { t, locale } = useI18n();
</script>

<template lang="pug">
v-btn.help-link(variant="plain" :href="manualUrl(path, locale)" target="_blank")
  span {{ t(label) }}
  common-icon.ml-1(size="small" name="mdi-open-in-new")
</template>
