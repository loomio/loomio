# Frontend and Vue instructions

## Frontend / Vue

- Write new Vue components in `<script setup>` format — even when sibling files in the same directory still use the Options API (much of the codebase is mid-migration; don't perpetuate the old style by matching neighbours).
  - Use the `useWatchRecords` composable from `@/composables/useWatchRecords` instead of the `WatchRecords` mixin.
  - Use `LmoUrlService.route({model})` directly instead of the `UrlFor` mixin.
  - Destructure `defineProps` and reference bare prop names (not `props.x`).
- Whenever editing a `.vue` template line that uses `v-t`, replace the directive with `{{ t(...) }}` interpolation and obtain `t` from `useI18n()`.
- In client code, do not guard `poll.topic()` or `discussion.topic()` with existence checks once the poll or discussion has been created. Topics are required for created polls and discussions; if a topic is missing, let it raise so the data integrity issue is visible.
- When doing frontend work, assume the user is already running the Vue dev server. Do not run `npm run build` after each frontend change unless the user asks, the change affects production build configuration, or there is a specific reason to verify the production build.
