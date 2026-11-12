import { mount } from '@vue/test-utils';
import { nextTick, reactive } from 'vue';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import BodyPreview from '@/components/topic/body_preview.vue';

vi.mock('vue-i18n', () => ({useI18n: () => ({t: key => key})}));

let wrapper, wrappers, height, resize, observers;
beforeEach(() => {
  height = 800;
  wrappers = [];
  observers = [];
  vi.stubGlobal('ResizeObserver', class {
    constructor(callback) {
      resize = callback;
      this.observe = vi.fn();
      this.unobserve = vi.fn();
      this.disconnect = vi.fn();
      observers.push(this);
    }
  });
  vi.spyOn(HTMLElement.prototype, 'getBoundingClientRect').mockImplementation(function() {
    return {height: this.classList.contains('body-preview__content') ? height : 320, top: 100};
  });
});
afterEach(() => { wrappers.forEach(item => item.unmount()); vi.unstubAllGlobals(); vi.restoreAllMocks(); });

function state(attributes = {}) {
  const preview = reactive({readBeforeVisit: true, revealed: false, changedSinceRead: false, ...attributes});
  preview.reveal = vi.fn(() => { preview.revealed = true; });
  return preview;
}

function render(preview, focused = false) {
  wrapper = mount(BodyPreview, {props: {state: preview, focused}, slots: {default: '<p>A long body</p>'},
    global: {stubs: {VBtn: {template: '<button><slot /></button>'}}}});
  wrappers.push(wrapper);
  return wrapper;
}

describe('already-read body previews', () => {
  it('caps a read body before the observer reports and expansion survives resizing', async () => {
    const preview = state();
    render(preview);
    expect(wrapper.classes()).toContain('body-preview--folded');
    await nextTick();
    expect(wrapper.find('button').exists()).toBe(true);
    await wrapper.find('button').trigger('click');
    height = 1000;
    resize([{target: wrapper.get('.body-preview__content').element}]);
    await nextTick();
    expect(wrapper.classes()).not.toContain('body-preview--folded');
    expect(preview.revealed).toBe(true);
    expect(wrapper.find('button').exists()).toBe(false);
  });

  it('keeps unread bodies fully revealed without a toggle', () => {
    render(state({readBeforeVisit: false}));
    expect(wrapper.classes()).not.toContain('body-preview--folded');
    expect(wrapper.find('button').exists()).toBe(false);
  });

  it('keeps bodies outside a thread preview fully visible', () => {
    render(undefined, true);
    expect(wrapper.classes()).not.toContain('body-preview--folded');
    expect(wrapper.find('button').exists()).toBe(false);
  });

  it('keeps short read bodies at their natural height without a toggle', async () => {
    height = 100;
    render(state());
    await nextTick();
    expect(wrapper.find('button').exists()).toBe(false);
    expect(wrapper.classes()).not.toContain('body-preview--folded');
  });

  it('does not preview a body just a few lines taller than the preview', async () => {
    height = 330;
    render(state());
    await nextTick();
    expect(wrapper.classes()).not.toContain('body-preview--folded');
    expect(wrapper.find('button').exists()).toBe(false);
    expect(observers).toHaveLength(0);
  });

  it('shares a resize observer and releases it after every observed body is revealed', async () => {
    const first = render(state());
    const second = render(state());
    await nextTick();
    expect(observers).toHaveLength(1);
    expect(observers[0].observe).toHaveBeenCalledTimes(2);
    await first.find('button').trigger('click');
    expect(observers[0].disconnect).not.toHaveBeenCalled();
    await second.find('button').trigger('click');
    expect(observers[0].disconnect).toHaveBeenCalledOnce();
  });

  it('reveals a body when the browser scrolls its clipped text into view', async () => {
    const scrollBy = vi.fn();
    vi.stubGlobal('scrollBy', scrollBy);
    const preview = state();
    render(preview);
    await nextTick();
    const viewport = wrapper.get('.body-preview__viewport');
    Object.defineProperty(viewport.element, 'scrollTop', {value: 180, configurable: true});
    await viewport.trigger('scroll');
    await nextTick();
    expect(preview.reveal).toHaveBeenCalledOnce();
    expect(wrapper.classes()).not.toContain('body-preview--folded');
    expect(scrollBy).toHaveBeenCalledWith({top: 180, behavior: 'instant'});
  });

  it('ignores scroll events that leave the preview at its start', async () => {
    const preview = state();
    render(preview);
    await nextTick();
    await wrapper.get('.body-preview__viewport').trigger('scroll');
    expect(preview.reveal).not.toHaveBeenCalled();
    expect(wrapper.classes()).toContain('body-preview--folded');
  });

  it('reveals a significant context change arriving after the body was folded', async () => {
    const preview = state();
    render(preview);
    await nextTick();
    preview.changedSinceRead = true;
    await nextTick();
    expect(wrapper.classes()).not.toContain('body-preview--folded');
    expect(preview.reveal).toHaveBeenCalledOnce();
  });

  it('reveals an explicitly focused item and keeps it revealed afterwards', async () => {
    const preview = state();
    render(preview, true);
    expect(wrapper.classes()).not.toContain('body-preview--folded');
    await wrapper.setProps({focused: false});
    expect(preview.revealed).toBe(true);
    expect(wrapper.classes()).not.toContain('body-preview--folded');
  });

  it('does not offer a body control on an explicitly linked read item', async () => {
    render(state(), true);
    await nextTick();
    expect(wrapper.find('button').exists()).toBe(false);
  });
});
