class HelpController < ApplicationController

  def help
    if I18n.locale == :en
      render 'en_help'
    else
      render 'help'
    end
  end
end
