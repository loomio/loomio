import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import PollPieIcon from '@/components/poll/common/icon/pie.vue';

describe('PollPieIcon', () => {
  it('renders the empty state as a grey circle', () => {
    const wrapper = mount(PollPieIcon, {props: {slices: [], size: 24}});

    expect(wrapper.attributes('viewBox')).toBe('0 0 24 24');
    expect(wrapper.get('circle').attributes()).toMatchObject({
      cx: '12',
      cy: '12',
      fill: '#BBBBBB',
      r: '12'
    });
  });

  it('renders one result as a solid circle', () => {
    const wrapper = mount(PollPieIcon, {
      props: {slices: [{color: '#123456', value: 100}], size: 32}
    });

    expect(wrapper.get('circle').attributes('fill')).toBe('#123456');
    expect(wrapper.findAll('path')).toHaveLength(0);
  });

  it('renders each result as a pie segment and reacts to changes', async () => {
    const wrapper = mount(PollPieIcon, {
      props: {
        slices: [
          {color: '#111111', value: 40},
          {color: '#222222', value: 60}
        ],
        size: 48
      }
    });

    expect(wrapper.findAll('path')).toHaveLength(2);
    expect(wrapper.findAll('path').map((path) => path.attributes('fill'))).toEqual(['#111111', '#222222']);

    await wrapper.setProps({slices: [{color: '#333333', value: 100}]});

    expect(wrapper.findAll('path')).toHaveLength(0);
    expect(wrapper.get('circle').attributes('fill')).toBe('#333333');
  });
});
