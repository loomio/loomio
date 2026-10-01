<script setup lang="js">
import { useI18n } from 'vue-i18n';
import { manualUrl } from '@/shared/helpers/manual_url';

const { path } = defineProps({
  path: String
});
const { t, locale } = useI18n();
</script>

<template lang="pug">
a.help-link.text-decoration-underline(
  style="color: inherit"
  :href="manualUrl(path, locale)"
  target="_blank"
  rel="noopener noreferrer"
)
  span {{ t('common.read_more') }}
  common-icon.ml-1(size="small" name="mdi-open-in-new")
</template>
