# frozen_string_literal: true

class RepositoryCheckMailer < ApplicationMailer
  def check_passed
    @check = params[:check]
    @repository = @check.repository
    user_email = @repository.user.email

    mail(to: user_email, subject: t('.subject', repository_full_name: @repository.full_name))
  end

  def check_failed
    @check = params[:check]
    @repository = @check.repository
    user_email = @repository.user.email

    mail(to: user_email, subject: t('.subject', repository_full_name: @repository.full_name))
  end
end
