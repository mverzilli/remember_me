class UserMailer < Devise::Mailer
  add_template_helper MailerHelper
  layout 'mail'
end