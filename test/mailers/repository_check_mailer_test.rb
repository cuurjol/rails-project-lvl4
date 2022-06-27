# frozen_string_literal: true

require 'test_helper'

class RepositoryCheckMailerTest < ActionMailer::TestCase
  def setup
    @check = repository_checks(:ruby_check)
    @repository = @check.repository
    @user_email = @repository.user.email
  end

  test 'check_passed' do
    mail = RepositoryCheckMailer.with(check: @check).check_passed
    mail.deliver_now

    subject = I18n.t('repository_check_mailer.check_passed.subject', repository_full_name: @repository.full_name)
    assert_emails(1)
    assert { mail.subject == subject }
    assert { mail.from.last == 'no-reply@herokuapp.com' }
    assert { mail.to.last == @user_email }
  end

  test 'check_failed' do
    mail = RepositoryCheckMailer.with(check: @check).check_failed
    mail.deliver_now

    subject = I18n.t('repository_check_mailer.check_failed.subject', repository_full_name: @repository.full_name)
    assert_emails(1)
    assert { mail.subject == subject }
    assert { mail.from.last == 'no-reply@herokuapp.com' }
    assert { mail.to.last == @user_email }
  end
end
