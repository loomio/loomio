<script setup lang="js">
import { ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import AskAiService from '@/shared/services/ask_ai_service';
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';

const props = defineProps({
  // Context targets (one of these should be provided)
  discussionId: { type: Number, default: null },
  groupId: { type: Number, default: null },
  pollId: { type: Number, default: null },
  outcomeId: { type: Number, default: null },

  // Optional: override via i18n key stems, eg: ['summarize','draft_outcome']
  suggestionKeys: { type: Array, default: null },

  // Optional requested result format ('html' | 'md'); if null, service will use user preference.
  resultFormat: { type: String, default: null },

  // Optional callback to receive the AI answer ({ answer, model, usage, id, prompt, format })
  onAnswer: { type: Function, default: null },
  scaffold: { type: Boolean, default: false },
  onScaffold: { type: Function, default: null },
});

const { t } = useI18n();

const promptText = ref('');
const loading = ref(false);

const canSubmit = computed(() => !loading.value && !!String(promptText.value).trim());

// Tailored suggestions by target type, localized via i18n keys
const suggestions = computed(() => {
  const S = (keys) => keys.map(k => ({
    title: t(`ask_ai.suggestions.${k}`),
    prompt: t(`ask_ai.suggestions.${k}_prompt`)
  }));
  return S(Array.isArray(props.suggestionKeys) ? props.suggestionKeys : []);
});

function selectSuggestion(text) {
  if (!text) return;
  promptText.value = text;
}

async function submit() {
  if (!canSubmit.value) return;
  loading.value = true;
  try {
    const target =
      props.discussionId ? { discussion_id: props.discussionId } :
      props.groupId      ? { group_id: props.groupId } :
      props.outcomeId    ? { outcome_id: props.outcomeId } :
      props.pollId       ? { poll_id: props.pollId } :
      {};

    if (props.scaffold) {
      // Scaffold poll (title, details, options) using the user's prompt
      const scaffold = await AskAiService.askScaffold(target, promptText.value);
      props.onScaffold(scaffold);
      Flash.success(t('ask_ai.messages.inserted'));
      EventBus.$emit('closeModal');
    } else {
      // Freeform ask, populate editor content
      console.log(props);
      const result = await AskAiService.ask(target, promptText.value)
      props.onAnswer(result);
      Flash.success(t('ask_ai.messages.inserted'));
      EventBus.$emit('closeModal');
    }
  } catch (e) {
    console.log(e);
    // AskAiService already maps and flashes appropriate error messages
  } finally {
    loading.value = false;
  }
}
</script>

<template lang="pug">
v-card.ask-ai-prompt-modal(:title="t('ask_ai.ask_ai')")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text
    .d-flex.align-center.mb-2(v-if="loading")
      v-progress-circular(indeterminate size="16" class="mr-2")
      span {{ t('ask_ai.messages.preparing') }}
    v-alert(type="info" variant="tonal" density="comfortable" class="mb-3")
      span {{ t('ask_ai.beta_notice') }}
    v-alert(type="info" variant="tonal" density="comfortable" class="mb-3" v-if="scaffold")
      span {{ t('ask_ai.scaffold_help') }}
    .mb-4
      v-menu
        template(v-slot:activator="{ props: activatorProps }")
          v-btn.text-transform-none(v-bind="activatorProps" variant="text" :disabled="loading")
            span {{ t('ask_ai.suggestions_placeholder') }}
        v-list
          v-list-item(
            v-for="(item, i) in suggestions"
            :key="i"
            lines="three"
            @click="selectSuggestion(item.prompt)"
          )
            v-list-item-title {{ item.title }}
            v-list-item-subtitle {{ item.prompt }}

    div
      v-textarea(
        v-model="promptText"
        :label="t('ask_ai.prompt_label')"
        auto-grow
        rows="3"
        :disabled="loading"
        :counter="5000"
        :placeholder="t('ask_ai.prompt_placeholder')"
      )
  v-card-actions
    v-spacer
    v-btn(
      color="primary"
      variant="elevated"
      :loading="loading"
      :disabled="!canSubmit"
      @click="submit"
    ) {{ t('ask_ai.ask_ai') }}
</template>
