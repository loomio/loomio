AppConfig = require 'shared/services/app_config'

module.exports = new class PaginationService
  windowFor: ({current, min, max, pageType}) ->
    pageSize = parseInt(AppConfig.pageSize[pageType]) or AppConfig.pageSize.default
    {
      current:  current
      min:      min
      max:      max
      prev:     _.max [current - pageSize, min] if current > min
      next:     current + pageSize              if current + pageSize < max
      pageSize: pageSize
    }
