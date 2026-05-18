<script lang="js">
import AppConfig from '@/shared/services/app_config';

let scriptLoadPromise = null;

function loadTurnstileScript() {
  if (window.turnstile) return Promise.resolve();
  if (scriptLoadPromise) return scriptLoadPromise;
  scriptLoadPromise = new Promise((resolve, reject) => {
    const s = document.createElement('script');
    s.src = 'https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit';
    s.async = true;
    s.defer = true;
    s.onload = () => resolve();
    s.onerror = () => reject(new Error('Failed to load Cloudflare Turnstile'));
    document.head.appendChild(s);
  });
  return scriptLoadPromise;
}

export default {
  props: {
    modelValue: { type: String, default: '' }
  },
  emits: ['update:modelValue'],

  data() {
    return {
      widgetId: null,
      siteKey: AppConfig.turnstileSiteKey
    };
  },

  mounted() {
    if (!this.siteKey) return;
    loadTurnstileScript().then(() => this.renderWidget()).catch(() => {
      // fail-closed on the UI: emit empty so submit stays disabled
      this.$emit('update:modelValue', '');
    });
  },

  beforeUnmount() {
    if (window.turnstile && this.widgetId) {
      try { window.turnstile.remove(this.widgetId); } catch (e) {}
    }
  },

  methods: {
    renderWidget() {
      if (!window.turnstile || !this.$refs.container) return;
      this.widgetId = window.turnstile.render(this.$refs.container, {
        sitekey: this.siteKey,
        callback: (token) => this.$emit('update:modelValue', token),
        'expired-callback': () => this.$emit('update:modelValue', ''),
        'error-callback': () => this.$emit('update:modelValue', '')
      });
    },
    reset() {
      if (window.turnstile && this.widgetId) {
        window.turnstile.reset(this.widgetId);
        this.$emit('update:modelValue', '');
      }
    }
  }
};
</script>
<template lang="pug">
.turnstile-widget.mt-4(v-if="siteKey")
  div(ref="container")
</template>
