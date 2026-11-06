import { describe, expect, it } from 'vitest';
import { loadEmojiEntries, searchEmojis } from '@/shared/helpers/emojis';

describe('emoji entries', () => {
  it('loads English entries with shortcodes and labels', async () => {
    const entries = await loadEmojiEntries('en');
    const heart = entries.find(entry => entry.shortcode === 'red_heart');
    expect(heart.label).toBe('red heart');
    expect(searchEmojis('red heart', entries)[0].shortcode).toBe('red_heart');
  });

  it('keeps English shortcodes and adds localized labels and search terms', async () => {
    const entries = await loadEmojiEntries('fr');
    const heart = entries.find(entry => entry.shortcode === 'red_heart');
    expect(heart.label).toBe('cœur rouge');
    expect(searchEmojis('amour', entries).map(entry => entry.shortcode)).toContain('red_heart');
    expect(searchEmojis('red heart', entries)[0].shortcode).toBe('red_heart');
  });
});
