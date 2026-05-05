<script lang="js">
import Records           from '@/shared/services/records';
import RecordLoader      from '@/shared/services/record_loader';
import EventBus          from '@/shared/services/event_bus';
import AbilityService    from '@/shared/services/ability_service';
import Session           from '@/shared/services/session';
import AttachmentService from '@/shared/services/attachment_service';

import { mdiMagnify } from '@mdi/js';
import { intersection, debounce, orderBy, uniq, escapeRegExp } from 'lodash-es';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';
import FormatDate from '@/mixins/format_date';

export default
{
  mixins: [WatchRecords, UrlFor, FormatDate],
  data() {
    return {
      group: null,
      attachmentLoader: null,
      searchQuery: '',
      items: [],
      subgroups: 'mine',
      attachmentIds: [],
      per: 25,
      from: 0,
      mdiMagnify
    };
  },

  created() {
    this.onQueryInput = debounce(val => {
      return this.$router.replace({ query: { q: val } });
    } , 400);

    this.group = Records.groups.fuzzyFind(this.$route.params.key);

    EventBus.$emit('currentComponent', {
      page: 'groupPage',
      title: this.group.name,
      group: this.group,
      search: {
        placeholder: this.$t('navbar.search_files', {name: this.group.parentOrSelf().name})
      }
    });

    this.attachmentLoader = new RecordLoader({
      collection: 'attachments',
      params: {
        group_id: this.group.id,
        per: this.per,
        subgroups: this.subgroups,
        from: this.from
      }
    });

    this.watchRecords({
      collections: ['attachments'],
      query: () => this.query()
    });

    this.searchQuery = this.$route.query.q || '';
    this.fetch();
  },

  watch: {
    '$route.query.q'(val) {
      this.searchQuery = val || '';
      this.fetch();
      this.query();
    }
  },

  methods: {
    query() {
      const attachments = Records.attachments.collection.chain().
                     find({id: {$in: this.attachmentIds}}).
                     find({filename: {$regex: new RegExp(`${escapeRegExp(this.searchQuery)}`, 'i')}}).
                     data();

      this.items = orderBy(attachments, 'createdAt', 'desc');
    },

    fetch() {
      this.attachmentLoader.fetchRecords({q: this.searchQuery}).then(data => {
        this.attachmentIds = uniq(this.attachmentIds.concat((data.attachments || []).map(a => a.id)));
      }).then(() => this.query());
    },

    actionsFor(item) {
      return AttachmentService.actions(item);
    }
  },

  computed: {
    showLoadMore() { return !this.attachmentLoader.exhausted; },
    loading() { return this.attachmentLoader.loading; },
    canAdminister() { return AbilityService.canAdminister(this.group); }
  }
};

</script>

<template lang="pug">
div
  .pt-4.pb-2
    v-text-field(
      clearable
      hide-details
      variant="solo"
      density="compact"
      @update:model-value="onQueryInput"
      :placeholder="$t('navbar.search_files_short')"
      :prepend-inner-icon="mdiMagnify")
  v-card.group-files-panel(outlined)
    div
      p.text-center.pa-4(v-if="!loading && !items.length" v-t="'common.no_results_found'")
      v-table(v-else :items="items" hide-default-footer)
        thead
          tr
            th(v-t="'group_files_panel.filename'")
            th(v-t="'group_files_panel.uploaded_by'")
            th(v-t="'group_files_panel.uploaded_at'")
            th(v-if="canAdminister")
        tbody
          tr(v-for="item in items" :key="item.id")
            td
              v-layout(align-center)
                common-icon.mr-2(:name="'mdi-'+ item.icon")
                a.text-on-surface(:href="item.downloadUrl") {{item.filename}}
            td
              user-avatar(:user="item.author()")
            td
              time-ago(:date="item.createdAt")
            td(v-if="canAdminister")
              action-menu(v-if="Object.keys(actionsFor(item)).length" :actions="actionsFor(item)" icon)

      .d.flex.justify-center
        .d-flex.flex-column.justify-center.align-center
          v-btn.my-2(
            variant="tonal"
            color='primary'
            v-if="!attachmentLoader.exhausted"
            :loading="loading"
            @click="fetch()"
          )
            span(v-t="'common.action.load_more'")
</template>
