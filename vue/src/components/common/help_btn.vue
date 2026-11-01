<script setup lang="js">
import { useI18n } from 'vue-i18n';
import { manualUrl } from '@/shared/helpers/manual_url';

const { path, label } = defineProps({
  path: String,
  label: {
    type: String,
    default: 'common.help'
  },
  variant: {
    type: String,
    default: 'plain'
  }
});
const { t, locale } = useI18n();
</script>

<template lang="pug">
v-btn.help-link(:variant="variant" :href="manualUrl(path, locale)" target="_blank" rel="noopener noreferrer")
  span {{ t(label) }}
  common-icon.ml-2(:size="24" name="mdi-open-in-new" aria-hidden="true")
</template>
