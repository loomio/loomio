import Flash from '@/shared/services/flash';
import AppConfig from '@/shared/services/app_config';
import utils from '@/shared/record_store/utils';

const resources = {
  discussion_template: 'discussion_templates',
  poll_template: 'poll_templates'
};

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

    const template = pickAttributes(data.template, AppConfig.templateSettings[type]);
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
        map(value => pickAttributes(value, AppConfig.templateSettings.poll_option));
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
