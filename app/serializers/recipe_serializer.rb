class RecipeSerializer < ApplicationSerializer
  attributes :id,
             :url,
             :title,
             :discussion_templates,
             :poll_templates
end
