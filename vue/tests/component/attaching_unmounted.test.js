import { mount } from '@vue/test-utils';
import { defineComponent, h, ref } from 'vue';
import { describe, expect, it } from 'vitest';
import { useAttaching } from '@/components/lmo_textarea/composables/useAttaching';

describe('useAttaching after the editor unmounts', () => {
  it('ignores a file chosen after its editor has gone', () => {
    let attaching;
    const filesField = ref(null);
    const imagesField = ref(null);
    const Editor = defineComponent({
      setup(_props, { emit }) {
        attaching = useAttaching(ref({attachments: []}), emit);
        return () => h('div', [
          h('input', {ref: filesField, type: 'file'}),
          h('input', {ref: imagesField, type: 'file'})
        ]);
      }
    });

    const wrapper = mount(Editor);
    wrapper.unmount();

    expect(filesField.value).toBeNull();
    expect(() => attaching.fileSelected(filesField)).not.toThrow();
    expect(() => attaching.imageSelected(imagesField, ref(null))).not.toThrow();
    expect(attaching.files.value).toEqual([]);
  });
});
