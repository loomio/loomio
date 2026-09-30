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
)
  span {{ t('common.read_more') }}
</template>
