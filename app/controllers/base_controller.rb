class BaseController < InheritedResources::Base
  before_filter :authenticate_user!
  # inherit_resources
end
