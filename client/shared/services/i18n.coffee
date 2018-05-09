ImplementationService = require 'shared/services/implementation_service'

module.exports = class I18n
  ImplementationService.requireMethod @, 't', 'setTranslateMethod'
  ImplementationService.requireMethod @, 'useLocale', 'setUseLocaleMethod'
