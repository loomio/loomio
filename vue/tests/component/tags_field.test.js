import { mount, flushPromises } from '@vue/test-utils';
import { reactive, nextTick } from 'vue';
import { createVuetify } from 'vuetify';
import { VAutocomplete, VCombobox } from 'vuetify/components';
import { beforeEach, afterEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({watchRecords: vi.fn(), user: {id: 1}}));
vi.mock('@/shared/services/session', () => ({default: {user: () => mocks.user}}));
vi.mock('@/composables/useWatchRecords', () => ({useWatchRecords: () => ({watchRecords: mocks.watchRecords})}));
vi.mock('vue-i18n', async importOriginal => ({
  ...await importOriginal(),
  useI18n: () => ({t: key => key})
}));

import TagsField from '@/components/tags/field.vue';

describe('tags field', () => {
  let wrapper;
  let group;
  let model;

  beforeEach(() => {
    vi.stubGlobal('ResizeObserver', class { observe() {} unobserve() {} disconnect() {} });
    vi.stubGlobal('visualViewport', undefined);
    vi.stubGlobal('matchMedia', () => ({matches: false, addEventListener() {}, removeEventListener() {}}));
    mocks.watchRecords.mockClear();
    group = {
      id: 1,
      membersCanCreateTags: false,
      membersInclude: () => true,
      adminsInclude: () => false,
      parentOrSelf: () => group,
      tags: () => [{name: 'Existing', color: '#123456'}]
    };
    model = reactive({groupId: 1, tags: [], group: () => group});
  });

  afterEach(() => {
    wrapper?.unmount();
    document.body.innerHTML = '';
    vi.unstubAllGlobals();
  });

  function mountField() {
    wrapper = mount(TagsField, {props: {model}, attachTo: document.body, global: {plugins: [createVuetify()]}});
    return wrapper;
  }

  it('lets a restricted member search and select an existing tag', async () => {
    mountField();
    const input = wrapper.find('input');
    await input.trigger('focus');
    await input.setValue('Exist');
    await flushPromises();
    const option = document.querySelector('.v-overlay .v-list-item');
    expect(option.textContent).toContain('Existing');
    option.click();
    await nextTick();

    expect(model.tags).toEqual(['Existing']);
    expect(wrapper.text()).toContain('Existing');
    await wrapper.find('.v-chip__close').trigger('click');
    expect(model.tags).toEqual([]);
  });

  it('does not add a new tag on Enter or blur when creation is disabled', async () => {
    mountField();
    const input = wrapper.find('input');
    await input.setValue('New tag');
    await input.trigger('keydown', {key: 'Enter'});
    await input.trigger('blur');
    await flushPromises();

    expect(model.tags).toEqual([]);
  });

  it('preserves tags supplied by a template even when they are absent from the options', () => {
    model.tags = ['Template tag'];
    mountField();

    expect(wrapper.findComponent(VAutocomplete).exists()).toBe(true);
    expect(wrapper.text()).toContain('Template tag');
    expect(model.tags).toEqual(['Template tag']);
  });

  it.each(['member', 'admin'])('allows a permitted %s to add a new tag', async role => {
    if (role === 'admin') { group.adminsInclude = () => true; }
    else { group.membersCanCreateTags = true; }
    mountField();
    const input = wrapper.find('input');
    await input.setValue('New tag');
    await input.trigger('keydown', {key: 'Enter'});
    await flushPromises();

    expect(model.tags).toEqual(['New tag']);
  });

  it('refreshes permissions and options after record-store updates', async () => {
    mountField();
    expect(wrapper.findComponent(VAutocomplete).exists()).toBe(true);
    group.membersCanCreateTags = true;
    group.tags = () => [{name: 'Added later'}];
    mocks.watchRecords.mock.calls[0][0].query();
    await nextTick();

    expect(wrapper.findComponent(VCombobox).exists()).toBe(true);
    expect(wrapper.findComponent(VCombobox).props('items')).toEqual(['Added later']);
  });

  it('refreshes tag creation permissions when switching groups', async () => {
    mountField();
    const nextGroup = {...group, membersCanCreateTags: true};
    model.group = () => nextGroup;
    model.groupId = 2;
    await nextTick();

    expect(wrapper.findComponent(VCombobox).exists()).toBe(true);
  });

  it('keeps free text tags available for direct threads', () => {
    model.groupId = null;
    mountField();

    expect(wrapper.findComponent(VCombobox).exists()).toBe(true);
  });
});
