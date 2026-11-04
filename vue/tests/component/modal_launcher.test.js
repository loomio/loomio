import { mount, flushPromises } from '@vue/test-utils';
import { createVuetify } from 'vuetify';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

vi.mock('@/shared/services/event_bus', () => ({default: {$on: vi.fn(), $off: vi.fn()}}));

import ModalLauncher from '@/components/modal/launcher.vue';

const content = {template: '<div><button>Dialog content</button></div>'};

describe('modal dismissal', () => {
  let wrapper;

  beforeEach(() => {
    vi.stubGlobal('ResizeObserver', class {observe() {} unobserve() {} disconnect() {}});
    vi.stubGlobal('visualViewport', undefined);
    vi.stubGlobal('matchMedia', () => ({matches: false, addEventListener() {}, removeEventListener() {}}));
    wrapper = mount({...ModalLauncher, components: {PollMembers: content, GroupForm: content}}, {
      attachTo: document.body,
      global: {plugins: [createVuetify()]}
    });
  });

  afterEach(() => {
    wrapper.unmount();
    document.body.innerHTML = '';
    vi.unstubAllGlobals();
  });

  async function escape() {
    window.dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape', bubbles: true}));
    await flushPromises();
  }

  it('closes a dismissible voter-management dialog with Escape', async () => {
    wrapper.vm.openModal({component: 'PollMembers', props: {}, persistent: false});
    await flushPromises();
    expect(wrapper.vm.isOpen).toBe(true);

    await escape();
    expect(wrapper.vm.isOpen).toBe(false);
  });

  it('restores persistence when the next dialog omits that option', async () => {
    wrapper.vm.openModal({component: 'PollMembers', props: {}, persistent: false});
    await flushPromises();
    wrapper.vm.closeModal();
    await flushPromises();
    wrapper.vm.openModal({component: 'GroupForm', props: {}});
    await flushPromises();

    await escape();
    expect(wrapper.vm.isOpen).toBe(true);
    wrapper.vm.closeModal();
    await flushPromises();
    expect(wrapper.vm.isOpen).toBe(false);
  });
});
