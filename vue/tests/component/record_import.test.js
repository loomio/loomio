import { describe, expect, it } from 'vitest';
import { computed, isReactive } from 'vue';
import Records from '@/shared/services/records';
import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';

// Count how often a computed evaluates, reading it after each change.
function counted(read) {
  let runs = 0;
  const result = computed(() => { runs++; return read(); });
  return {value: () => result.value, runs: () => runs};
}

const commentJSON = (id, attributes = {}) => ({
  id, discussion_id: 1, author_id: 50 + id, body: `<p>comment ${id}</p>`,
  created_at: '2026-01-01T00:00:00.000Z', mentioned_usernames: ['someone'], ...attributes
});

describe('record import', () => {
  it('does not re-run computeds when the same JSON is imported again', () => {
    Records.importJSON({comments: [commentJSON(101)]});
    const comment = Records.comments.find(101);
    const fields = counted(() => [comment.createdAt.getTime(), comment.mentionedUsernames.length, comment.body]);
    fields.value();

    Records.importJSON({comments: [commentJSON(101)]});
    fields.value();
    expect(fields.runs()).toBe(1);

    Records.importJSON({comments: [commentJSON(101, {body: '<p>edited</p>'})]});
    expect(fields.value()[2]).toBe('<p>edited</p>');
    expect(fields.runs()).toBe(2);
  });

  it('updates a computed query when an import adds a matching record', () => {
    // authorId is indexed, so a comment by someone else does not re-run it.
    const authored = counted(() => Records.comments.find({authorId: 2007}).map(comment => comment.id));
    expect(authored.value()).toEqual([]);

    Records.importJSON({comments: [commentJSON(201, {author_id: 2008})]});
    expect(authored.value()).toEqual([]);
    expect(authored.runs()).toBe(1);

    Records.importJSON({comments: [commentJSON(202, {author_id: 2007})]});
    expect(authored.value()).toEqual([202]);
  });

  it('updates a relationship when the related record arrives later', () => {
    Records.importJSON({comments: [commentJSON(301, {author_id: 3001})]});
    const comment = Records.comments.find(301);
    const authorName = counted(() => comment.author().name);
    expect(authorName.value()).toBe('Anonymous');

    Records.importJSON({users: [{id: 3001, name: 'Late Author'}]});
    expect(authorName.value()).toBe('Late Author');
  });

  it('builds reactive records whose methods write through the proxy', () => {
    const comment = new Records.comments.model({id: 401});
    expect(isReactive(comment)).toBe(true);
    const errors = counted(() => comment.errors.body);
    expect(errors.value()).toBeUndefined();

    comment.setErrors({body: ['is too long']});
    expect(errors.value()).toEqual(['is too long']);
  });

  it('re-runs a query on the signed-in user when someone signs in', () => {
    AppConfig.currentUserId = null;
    const bookmarks = counted(() => Records.bookmarks.find({userId: Session.userId}).length);
    expect(bookmarks.value()).toBe(0);

    AppConfig.currentUserId = 501;
    Records.importJSON({bookmarks: [{id: 1, user_id: 501, bookmarkable_id: 1, bookmarkable_type: 'Topic'}]});
    expect(bookmarks.value()).toBe(1);
  });
});
