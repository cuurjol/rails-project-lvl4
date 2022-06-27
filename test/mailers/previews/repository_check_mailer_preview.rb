# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/repository_check_mailer
class RepositoryCheckMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/repository_check_mailer/check_passed
  def check_passed
    RepositoryCheckMailer.with(check: Repository::Check.first).check_passed
  end

  # Preview this email at http://localhost:3000/rails/mailers/repository_check_mailer/check_failed
  def check_failed
    RepositoryCheckMailer.with(check: Repository::Check.first).check_failed
  end
end
