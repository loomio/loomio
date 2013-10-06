module Kaminari
  module Helpers
    class Tag
      def page_url_for(page)
        @template.url_for @params.merge(@param_name => (page <= 1 ? 1 : page))
      end
    end
  end
end
