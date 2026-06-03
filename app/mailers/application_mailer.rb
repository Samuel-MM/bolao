class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "bolao@example.com")
  layout "mailer"
end
