class HelpController < ApplicationController

  def help
  end

  def markdown_help
  	render layout: false
  end

end
