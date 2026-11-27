<script setup lang="js">
import { computed, ref } from 'vue';
import { useI18n } from 'vue-i18n';

const { page, totalPages, pageSize, pageSizeOptions, sort, sortOptions, disabled } = defineProps({
  page: { type: Number, required: true },
  totalPages: { type: Number, required: true },
  pageSize: { type: Number, default: 25 },
  pageSizeOptions: { type: Array, default: () => [25, 50, 100] },
  sort: { type: String, default: null },
  sortOptions: { type: Array, default: () => [] },
  disabled: { type: Boolean, default: false }
});

const emit = defineEmits(['update:page', 'update:pageSize', 'update:sort']);
const { t } = useI18n();

const open = ref(false);

const hasMultiplePages = computed(() => totalPages > 1);
const hasSortOptions = computed(() => sortOptions.length > 1);
const pages = computed(() => Array.from({ length: totalPages }, (_, i) => i + 1));

function goToPage(nextPage) {
  open.value = false;
  if (nextPage >= 1 && nextPage <= totalPages && nextPage !== page) {
    emit('update:page', nextPage);
  }
}

function selectSort(value) {
  open.value = false;
  if (value !== sort) {
    emit('update:sort', value);
  }
}

function selectPageSize(size) {
  open.value = false;
  if (size !== pageSize) {
    emit('update:pageSize', size);
  }
}
</script>

<template lang="pug">
.list-pagination.d-flex.align-center.justify-center.ga-1.py-3
  v-btn.list-pagination__prev(
    icon
    density="comfortable"
    variant="text"
    :disabled="disabled || page <= 1"
    :aria-label="t('pagination.previous_page')"
    @click="goToPage(page - 1)"
  )
    common-icon(name="mdi-chevron-left")

  v-menu(v-model="open" location="top center" :close-on-content-click="false")
    template(#activator="{ props }")
      v-btn.list-pagination__menu-btn.text-medium-emphasis(
        v-bind="props"
        variant="tonal"
        density="comfortable"
        :disabled="disabled"
      )
        span {{ t('pagination.page_of', { page, total: totalPages }) }}
        common-icon(name="mdi-menu-down")

    v-card.list-pagination__menu(min-width="240" max-width="280")
      v-list(density="compact")
        template(v-if="hasMultiplePages")
          v-list-subheader {{ t('pagination.jump_to_page') }}
          .list-pagination__page-grid.px-3.pb-2
            v-btn.list-pagination__page-btn(
              v-for="n in pages"
              :key="n"
              size="small"
              :variant="n === page ? 'tonal' : 'text'"
              :color="n === page ? 'primary' : undefined"
              @click="goToPage(n)"
            ) {{ n }}

        template(v-if="hasSortOptions")
          v-divider(v-if="hasMultiplePages")
          v-list-subheader {{ t('pagination.sort_by') }}
          v-list-item.list-pagination__sort-option(
            v-for="opt in sortOptions"
            :key="opt.value"
            :active="sort === opt.value"
            :data-sort="opt.value"
            @click="selectSort(opt.value)"
          )
            v-list-item-title {{ opt.label }}
            template(#append)
              common-icon(v-if="sort === opt.value" name="mdi-check" size="small")

        template(v-if="pageSizeOptions.length > 1")
          v-divider(v-if="hasMultiplePages || hasSortOptions")
          v-list-subheader {{ t('pagination.per_page') }}
          .d-flex.ga-1.px-3.pb-2
            v-btn.list-pagination__size-btn.flex-grow-1(
              v-for="size in pageSizeOptions"
              :key="size"
              size="small"
              :variant="size === pageSize ? 'tonal' : 'text'"
              :color="size === pageSize ? 'primary' : undefined"
              @click="selectPageSize(size)"
            ) {{ size }}

  v-btn.list-pagination__next(
    icon
    density="comfortable"
    variant="text"
    :disabled="disabled || page >= totalPages"
    :aria-label="t('pagination.next_page')"
    @click="goToPage(page + 1)"
  )
    common-icon(name="mdi-chevron-right")
</template>

<style scoped>
.list-pagination__page-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 4px;
  max-height: 180px;
  overflow-y: auto;
}

.list-pagination__page-btn {
  min-width: 0;
  padding: 0 4px;
}
</style>
