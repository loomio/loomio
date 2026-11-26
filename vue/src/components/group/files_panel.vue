<script lang="js">
import Records           from '@/shared/services/records';
import RecordLoader      from '@/shared/services/record_loader';
import EventBus          from '@/shared/services/event_bus';
import GroupAbility from '@/shared/abilities/group_ability';

import { mdiMagnify } from '@mdi/js';
import { debounce, orderBy, uniq, escapeRegExp } from 'lodash-es';
import SubgroupsFilterMenu from '@/components/group/subgroups_filter_menu.vue';
import UrlFor from '@/mixins/url_for';
import FormatDate from '@/mixins/format_date';

const cachedAttachmentIds = new Map();

export default
{
  components: { SubgroupsFilterMenu },
  mixins: [UrlFor, FormatDate],
  props: {
    dashboard: { type: Boolean, default: false }
  },
  data() {
    return {
      group: null,
      attachmentLoader: null,
      searchQuery: '',
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

    this.group = this.dashboard ? null : Records.groups.fuzzyFind(this.$route.params.key);

    if (this.group) {
      EventBus.$emit('currentComponent', {
        page: 'groupPage',
        title: this.group.name,
        group: this.group,
        search: {
          placeholder: this.$t('navbar.search_files', {name: this.group.parentOrSelf().name})
        }
      });
    }

    const params = { per: this.per, from: this.from };
    if (this.group) {
      params.group_id = this.group.id;
      if (this.subgroupsFilter) { params.subgroups = this.subgroupsFilter; }
    }
    this.attachmentLoader = new RecordLoader({
      collection: 'attachments',
      params
    });

    this.searchQuery = this.$route.query.q || '';
    this.attachmentIds = cachedAttachmentIds.get(this.cacheKey) || [];
    this.fetch();
  },

  watch: {
    '$route.query.q'(val) {
      this.searchQuery = val || '';
      this.fetch();
    },
    '$route.query.subgroups'() {
      this.attachmentIds = cachedAttachmentIds.get(this.cacheKey) || [];
      const params = { per: this.per, from: 0 };
      if (this.group) {
        params.group_id = this.group.id;
        if (this.subgroupsFilter) { params.subgroups = this.subgroupsFilter; }
      }
      this.attachmentLoader = new RecordLoader({ collection: 'attachments', params });
      this.fetch();
    }
  },

  methods: {
    selectSubgroups(val) {
      const query = Object.assign({}, this.$route.query);
      if (val) { query.subgroups = val; } else { delete query.subgroups; }
      this.$router.replace({ query });
    },
    fetch() {
      this.attachmentLoader.fetchRecords({q: this.searchQuery}).then(data => {
        // RecordLoader resolves a failed request after recording its error.
        if (this.attachmentLoader.err) { return; }
        this.attachmentIds = uniq(this.attachmentIds.concat((data.attachments || []).map(a => a.id)));
        if (!this.searchQuery) {
          cachedAttachmentIds.set(this.cacheKey, this.attachmentIds);
        }
      });
    },

    deleteAttachment(item) {
      EventBus.$emit('openModal', {
        component: 'ConfirmModal',
        props: {
          confirm: {
            submit: () => item.destroy(),
            text: {
              title: 'comment_form.attachments.remove_attachment',
              helptext: 'group_files_panel.delete_confirmation',
              submit: 'common.action.delete',
              flash: 'poll_common_delete_modal.success'
            }
          }
        }
      });
    }
  },

  computed: {
    subgroupsFilter() {
      if (!this.group || !(this.group.subgroupsCount > 0)) { return null; }
      return ['mine', 'all'].includes(this.$route.query.subgroups) ? this.$route.query.subgroups : null;
    },
    cacheKey() {
      return `${this.group ? this.group.id : 'dashboard'}:${this.subgroupsFilter || 'none'}`;
    },
    items() {
      const attachments = Records.attachments.collection.chain().
                     find({id: {$in: this.attachmentIds}}).
                     find({filename: {$regex: new RegExp(`${escapeRegExp(this.searchQuery)}`, 'i')}}).
                     data();

      return orderBy(attachments, 'createdAt', 'desc');
    },
    showLoadMore() { return !this.attachmentLoader.exhausted; },
    loading() { return this.attachmentLoader.loading; },
    canAdminister() { return Boolean(this.group) && GroupAbility.canUpdate(this.group); }
  }
};

</script>

<template lang="pug">
div
  .d-flex.align-center.flex-wrap.ga-2.pt-4.pb-2
    subgroups-filter-menu(v-if="group" :group="group" :selected="subgroupsFilter" @select="selectSubgroups")
    v-text-field.flex-grow-1(
      clearable
      hide-details
      variant="solo"
      density="compact"
      @update:model-value="onQueryInput"
      :placeholder="$t('navbar.search_files_short')"
      :prepend-inner-icon="mdiMagnify")
  v-card.group-files-panel(variant="flat")
    div
      loading(v-if="loading && !items.length")
      p.text-center.pa-4(v-else-if="!loading && !items.length" v-t="'common.no_results_found'")
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
                a.text-medium-emphasis.text-decoration-none(:href="item.downloadUrl") {{item.filename}}
            td
              user-avatar(:user="item.author()")
            td
              time-ago(:date="item.createdAt")
            td(v-if="canAdminister")
              action-button(variant="flat" :action="{name: 'common.action.delete', icon: 'mdi-delete', dock: 1, perform: () => deleteAttachment(item)}")

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
