import { mount } from '@vue/test-utils';
import { defineComponent, h, ref } from 'vue';
import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({user: {id: 2}, upload: vi.fn()}));
vi.mock('@/shared/services/session', () => ({default: {user: () => mocks.user}}));
vi.mock('@/shared/services/file_uploader', () => ({default: class {
  upload(file) { return mocks.upload(file); }
}}));

import AbilityService from '@/shared/services/ability_service';
import { useAttaching } from '@/components/lmo_textarea/composables/useAttaching';
import { contentExtensions } from '@/components/lmo_textarea/content_extensions';
import { Editor } from '@tiptap/core';

const topic = {attachmentsAdminOnly: true, adminsInclude: user => user.id === 1};
const modelFor = kind => ({
  constructor: {singular: kind}, attachments: [], files: null, imageFiles: null,
  topicId: 7, topic: () => topic, poll: () => ({topic: () => topic})
});

beforeEach(() => {
  mocks.user = {id: 2};
  mocks.upload.mockReset().mockResolvedValue({signed_id: 'uploaded'});
  topic.attachmentsAdminOnly = true;
});

describe('attachment permissions in editors', () => {
  it.each(['discussion', 'poll', 'comment', 'stance', 'outcome'])('uses the containing topic for a %s', kind => {
    const model = modelFor(kind);
    expect(AbilityService.canAttachFiles(model)).toBe(false);
    mocks.user = {id: 1};
    expect(AbilityService.canAttachFiles(model)).toBe(true);
    mocks.user = {id: 2};
    topic.attachmentsAdminOnly = false;
    expect(AbilityService.canAttachFiles(model)).toBe(true);
  });

  it('allows initial context files and template editing', () => {
    for (const kind of ['discussion', 'poll', 'discussionTemplate', 'pollTemplate', 'user', 'group']) {
      expect(AbilityService.canAttachFiles({...modelFor(kind), topicId: null})).toBe(true);
    }
  });

  it('blocks file and media uploads and reacts when the topic restriction changes', async () => {
    let attaching;
    const model = ref(modelFor('comment'));
    const wrapper = mount(defineComponent({setup() {
      attaching = useAttaching(model);
      return () => h('div');
    }}));
    const file = new File(['contents'], 'document.txt');
    const onFailure = vi.fn();
    attaching.attachFile({file});
    attaching.attachImageFile({file, onFailure});
    expect(mocks.upload).not.toHaveBeenCalled();
    expect(onFailure).toHaveBeenCalledOnce();
    expect(attaching.files.value).toEqual([]);
    model.value.topic = () => ({...topic, attachmentsAdminOnly: false});
    attaching.attachFile({file});
    await vi.waitFor(() => expect(mocks.upload).toHaveBeenCalledWith(file));
    wrapper.unmount();
  });

  it('ignores pasted and dropped files before adding rich-text upload placeholders', () => {
    const attachFile = vi.fn();
    const attachImageFile = vi.fn();
    let allowed = false;
    const editor = new Editor({
      extensions: contentExtensions({attachFile, attachImageFile, canAttachFiles: () => allowed}),
      content: '<p>Reply</p>'
    });
    const files = [new File(['image'], 'reply.png', {type: 'image/png'})];
    const paste = {clipboardData: {files, items: [{getAsFile: () => files[0]}], getData: () => ''}, preventDefault: vi.fn()};
    const drop = {dataTransfer: {files}, preventDefault: vi.fn()};
    editor.view.someProp('handleDOMEvents', handlers => handlers.paste?.(editor.view, paste));
    editor.view.someProp('handleDOMEvents', handlers => handlers.drop?.(editor.view, drop));
    expect(paste.preventDefault).toHaveBeenCalled();
    expect(drop.preventDefault).toHaveBeenCalled();
    expect(attachFile).not.toHaveBeenCalled();
    expect(attachImageFile).not.toHaveBeenCalled();
    expect(editor.getHTML()).toBe('<p>Reply</p>');
    allowed = true;
    editor.view.someProp('handleDOMEvents', handlers => handlers.paste?.(editor.view, paste));
    expect(attachImageFile).toHaveBeenCalledOnce();
    editor.destroy();
  });
});
