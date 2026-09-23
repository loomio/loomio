import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import PollBarIcon from '@/components/poll/common/icon/bar.vue';

describe('PollBarIcon', () => {
  it('renders a placeholder when the poll has no scores', () => {
    const wrapper = mount(PollBarIcon, {
      props: {poll: {stanceCounts: []}, size: 30}
    });
    const bars = wrapper.findAll('rect');

    expect(bars).toHaveLength(3);
    expect(bars.map((bar) => bar.attributes('width'))).toEqual(['30', '20', '10']);
  });

  it('scales the first five scores against the largest score', () => {
    const wrapper = mount(PollBarIcon, {
      props: {poll: {stanceCounts: [10, 5, 1, 0, 8, 9]}, size: 50}
    });
    const bars = wrapper.findAll('rect');

    expect(bars).toHaveLength(5);
    expect(bars.map((bar) => bar.attributes('width'))).toEqual(['50', '25', '5', '2', '40']);
  });

  it('reacts when score data changes', async () => {
    const wrapper = mount(PollBarIcon, {
      props: {poll: {stanceCounts: []}, size: 24}
    });

    await wrapper.setProps({poll: {stanceCounts: [2, 1]}});

    expect(wrapper.findAll('rect')).toHaveLength(2);
    expect(wrapper.findAll('rect').map((bar) => bar.attributes('width'))).toEqual(['24', '12']);
  });
});
