import { describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  built: null,
  record: () => ({ update(attrs) { mocks.built = attrs; } })
}));

vi.mock('@/shared/services/app_config', () => ({
  default: {
    templateSettings: {
      poll_template: ['poll_type', 'agree_target', 'notify_on_open', 'content_locale', 'poll_options', 'tags'],
      discussion_template: ['title', 'content_locale', 'allow_reactions', 'tags']
    }
  }
}));
vi.mock('@/shared/services/session', () => ({ default: { user: () => ({ id: 1 }) } }));
vi.mock('@/shared/services/records', () => ({
  default: { polls: { build: mocks.record }, discussions: { build: mocks.record } }
}));
vi.mock('@/i18n', () => ({ I18n: { global: { t: (key) => key } } }));

import PollTemplateModel from '@/shared/models/poll_template_model';
import DiscussionTemplateModel from '@/shared/models/discussion_template_model';

describe('starting from a template', () => {
  it('copies every poll template setting onto the poll', () => {
    const template = {
      id: 5, key: null, groupId: 8, defaultDurationInDays: 3,
      pollType: 'proposal', agreeTarget: 4, notifyOnOpen: false, contentLocale: 'fr',
      pollOptions: [{ name: 'Agree' }], tags: ['Decision'],
      pollOptionsAttributes: () => [{ name: 'Agree' }]
    };

    PollTemplateModel.prototype.buildPoll.call(template);

    expect(mocks.built).toMatchObject({
      pollType: 'proposal', agreeTarget: 4, notifyOnOpen: false, contentLocale: 'fr',
      groupId: 8, pollTemplateId: 5, pollOptionsAttributes: [{ name: 'Agree' }], tags: ['Decision']
    });
    expect(mocks.built).not.toHaveProperty('pollOptions');
    mocks.built.tags.push('Draft only');
    expect(template.tags).toEqual(['Decision']);
  });

  it('copies every discussion template setting onto the discussion', () => {
    const template = { id: 6, key: null, title: 'Plan', contentLocale: 'de', allowReactions: false, tags: ['Planning'] };

    DiscussionTemplateModel.prototype.buildDiscussion.call(template);

    expect(mocks.built).toMatchObject({ title: 'Plan', contentLocale: 'de', allowReactions: false, discussionTemplateId: 6, tags: ['Planning'] });
    mocks.built.tags.push('Draft only');
    expect(template.tags).toEqual(['Planning']);
  });
});
