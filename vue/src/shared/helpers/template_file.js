import Flash from '@/shared/services/flash';
import AppConfig from '@/shared/services/app_config';
import utils from '@/shared/record_store/utils';

const resources = {
  discussion_template: 'discussion_templates',
  poll_template: 'poll_templates'
};

const attributes = {
  discussion_template: [
    'title', 'title_placeholder', 'description', 'description_format',
    'process_name', 'process_subtitle', 'process_introduction',
    'process_introduction_format', 'recipient_audience', 'newest_first',
    'max_depth', 'allow_concurrent_polls', 'allow_comments', 'allow_reactions',
    'comment_length_max', 'public', 'default_to_direct_discussion',
    'poll_template_keys_or_ids', 'tags', 'content_locale'
  ],
  poll_template: [
    'poll_type', 'process_name', 'process_subtitle', 'process_introduction',
    'process_introduction_format', 'title', 'title_placeholder', 'details',
    'details_format', 'anonymous', 'specified_voters_only',
    'notify_on_closing_soon', 'notify_on_open', 'content_locale',
    'shuffle_options', 'show_none_of_the_above', 'hide_results', 'chart_type',
    'min_score', 'max_score', 'minimum_stance_choices',
    'maximum_stance_choices', 'dots_per_person', 'reason_prompt', 'tags',
    'poll_options', 'stance_reason_required', 'limit_reason_length',
    'default_duration_in_days', 'agree_target', 'meeting_duration',
    'can_respond_maybe', 'poll_option_name_format', 'outcome_statement',
    'outcome_statement_format', 'outcome_review_due_in_days', 'quorum_pct',
    'allow_comments', 'allow_reactions', 'comment_length_max'
  ]
};

const pollOptionAttributes = [
  'name', 'icon', 'meaning', 'prompt', 'priority', 'test_operator',
  'test_percent', 'test_against'
];

const pendingTemplates = {};

export function exportTemplateFile(type, template, groupId) {
  const resource = resources[type];
  const id = template.id || template.key;
  const link = document.createElement('a');
  link.href = `/api/v1/${resource}/${encodeURIComponent(id)}/export?group_id=${groupId}`;
  link.click();
}

const pickAttributes = (source, keys) => Object.fromEntries(
  keys.filter(key => Object.hasOwn(source, key)).map(key => [key, source[key]])
);

export async function importTemplateFile(type, file) {
  try {
    const data = JSON.parse(await file.text()).loomio_template;
    if (Number(data.version) !== 1 || data.type !== type || !data.template || Array.isArray(data.template)) {
      throw new Error('Invalid template file');
    }

    const template = pickAttributes(data.template, attributes[type]);
    template.tags = Array.isArray(template.tags) ? template.tags.filter(value => typeof value === 'string') : [];
    if (type === 'discussion_template') {
      template.poll_template_keys_or_ids = (template.poll_template_keys_or_ids || []).
        filter(value => typeof value === 'string' && !/^\d+$/.test(value));
    } else {
      if (!AppConfig.pollTypes[template.poll_type]) {
        throw new Error('Unsupported poll type');
      }
      template.poll_options = (template.poll_options || []).
        filter(value => value && typeof value === 'object' && !Array.isArray(value)).
        map(value => pickAttributes(value, pollOptionAttributes));
    }

    pendingTemplates[type] = utils.parseJSON(template);
    return true;
  } catch (error) {
    Flash.error('templates.invalid_template_file');
    return false;
  }
}

export function takeImportedTemplate(type) {
  const template = pendingTemplates[type];
  delete pendingTemplates[type];
  return template;
}
