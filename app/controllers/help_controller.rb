class HelpController < ApplicationController
  def markdown
    render layout: false
  end
  def api
    render layout: 'basic'
  end
end
