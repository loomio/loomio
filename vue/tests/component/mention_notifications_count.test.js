import { flushPromises, mount } from '@vue/test-utils';
import { afterEach, expect, it, vi } from 'vitest';

vi.mock('@/shared/services/records', () => ({default: {remote: {fetch: vi.fn()}}}));

import Records from '@/shared/services/records';
import MentionNotificationsCount from '@/components/common/mention_notifications_count.vue';

afterEach(() => vi.useRealTimers());

it('refreshes the notification count only when the mention set changes', async () => {
  vi.useFakeTimers();
  const fetch = vi.mocked(Records.remote.fetch).mockResolvedValue({count: 2});
  const model = {
    isA: (...types) => types.includes('comment'),
    topic: () => ({namedId: () => ({topic_id: 42})})
  };
  const wrapper = mount(MentionNotificationsCount, {
    props: {model, handles: ['alex', 'sam']},
    global: {directives: {t: (element, {value}) => { element.textContent = value.path || value; }}}
  });

  try {
    await vi.advanceTimersByTimeAsync(150);
    expect(fetch).toHaveBeenCalledTimes(1);

    await wrapper.setProps({handles: ['alex', 'sam']});
    await vi.advanceTimersByTimeAsync(150);
    await wrapper.setProps({handles: ['sam', 'alex']});
    await vi.advanceTimersByTimeAsync(150);
    expect(fetch).toHaveBeenCalledTimes(1);

    await wrapper.setProps({handles: ['sam']});
    await vi.advanceTimersByTimeAsync(150);
    expect(fetch).toHaveBeenCalledTimes(2);
    expect(fetch).toHaveBeenLastCalledWith({
      path: 'mentions/count',
      params: {handles_cmr: 'sam', topic_id: 42}
    });

    let resolveOutdatedCount;
    fetch.mockReturnValueOnce(new Promise(resolve => { resolveOutdatedCount = resolve; }));
    await wrapper.setProps({handles: ['alex']});
    await vi.advanceTimersByTimeAsync(150);

    await wrapper.setProps({handles: []});
    await vi.advanceTimersByTimeAsync(150);
    expect(fetch).toHaveBeenCalledTimes(3);

    await wrapper.setProps({handles: ['sam']});
    fetch.mockResolvedValueOnce({count: 1});
    await vi.advanceTimersByTimeAsync(150);
    resolveOutdatedCount({count: 2});
    await flushPromises();
    expect(wrapper.text()).toBe('mention_notifications_count.one_person_will_be_notified');
  } finally {
    wrapper.unmount();
  }
});
