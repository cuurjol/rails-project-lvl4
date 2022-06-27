# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default(from: 'no-reply@herokuapp.com')
  layout('mailer')
end
