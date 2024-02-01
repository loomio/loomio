let RescueUnsavedEditsService;
import {some, intersection, pick, uniq} from 'lodash-es';
import I18n from '@/i18n';

export default new class RescueUnsavedEditsService {
  constructor() {
    this.models = [];
  }

  okToLeave(model) {
    const attrs = [
      'description',
      'title',
      'body',
      'details',
      'name',
      'reason',
      'statement',
      'titlePlaceholder',
      'processIntroduction',
      'processName',
      'processSubtitle'
    ];
    const models = uniq(((model && [model]) || this.models).flat());
    models.forEach(m => m.beforeSaves.forEach(f => f()));
    if (some(models, m => intersection(attrs, m.modifiedAttributes()).length > 0)) {
      // console.log 'some modified', @models.map (m) ->
      //   modifiedAttrs = intersection(attrs, m.modifiedAttributes())
      //   if modifiedAttrs.length > 0
      //     o = {}
      //     o['new'] = pick(m, modifiedAttrs)
      //     o['old'] = pick(m.unmodified, modifiedAttrs)
      //     o
      //   else
      //     null

      const ms = uniq(this.models.map(m => m.constructor.singular));
      const as = uniq((this.models.map(m => intersection(attrs, m.modifiedAttributes()))).flat().flat());

      // if confirm("#{ms.join(' ') } #{as.join(' ')} #{models[0][as[0]]}")
      if (confirm(I18n.t('common.confirm_discard_changes'))) {
        return (model && model.discardChanges()) || true;
      } else {
        return false;
      }
    } else {
      this.models = [];
      return true;
    }
  }

  add(model) {
    return this.models.push(model);
  }

  clear() {
    return this.models = [];
  }
};
