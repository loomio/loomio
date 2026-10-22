import { beforeEach, describe, expect, it, vi } from 'vitest';

vi.mock('@/shared/services/flash', () => ({ default: { error: vi.fn() } }));
vi.mock('@/shared/services/app_config', () => ({ default: {
  templateSettings: {
    poll_template: ['poll_type', 'notify_on_closing_soon', 'recipient_audience', 'poll_options'],
    discussion_template: ['recipient_audience', 'poll_template_keys_or_ids'],
    poll_option: ['name']
  },
  pollTypes: { proposal: {} }
} }));

import { importTemplateFile, takeImportedTemplate } from '@/shared/helpers/template_file';

describe('portable templates created before the participation rename', () => {
  beforeEach(() => {
    takeImportedTemplate('poll_template');
    takeImportedTemplate('discussion_template');
  });

  async function importTemplate(type, template) {
    const file = { text: async () => JSON.stringify({ loomio_template: { version: 1, type, template } }) };
    expect(await importTemplateFile(type, file)).toBe(true);
    return takeImportedTemplate(type);
  }

  it('keeps reminders aimed at people who have not voted', async () => {
    const template = await importTemplate('poll_template', {
      poll_type: 'proposal', notify_on_closing_soon: 'undecided_voters',
      poll_options: [{ name: 'Agree' }]
    });
    expect(template.notifyOnClosingSoon).toBe('voters_uncast');
    expect(template.pollOptions).toEqual([{ name: 'Agree' }]);
  });

  it.each([
    ['decided_voters', 'voters_cast'], ['undecided_voters', 'voters_uncast'], ['group', 'group']
  ])('preserves the recipients of a %s discussion template', async (before, after) => {
    const template = await importTemplate('discussion_template', { recipient_audience: before });
    expect(template.recipientAudience).toBe(after);
  });
});
