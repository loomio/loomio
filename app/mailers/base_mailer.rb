class BaseMailer < ActionMailer::Base
  default from: '"Loomio" <contact@loomio.org>', css: :email
end
