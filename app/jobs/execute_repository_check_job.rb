# frozen_string_literal: true

class ExecuteRepositoryCheckJob < ApplicationJob
  queue_as :default

  def perform(check_id)
    check = Repository::Check.find(check_id)

    begin
      start_process(check)
    rescue StandardError => e
      Rails.logger.debug(e.full_message)
      reject_process(check)
    ensure
      finish_process(check)
    end
  end

  private

  def start_process(check)
    ApplicationContainer[:repository_manager].clone_repository(check.repository)
    check.update!(check_params(check.repository))
    check.finish!
  end

  def reject_process(check)
    check.passed = false
    check.reject!
  end

  def finish_process(check)
    mailer_action = check.passed? ? :check_passed : :check_failed
    RepositoryCheckMailer.with(check: check).send(mailer_action).deliver_now
    ApplicationContainer[:repository_manager].remove_repository(check.repository)
  end

  def check_params(repository)
    scan_result = ApplicationContainer[:repository_manager].scan_repository(repository)
    github_client = ApplicationContainer[:github_client].new(repository.user.id, repository.user.token)
    linter_parser = "parsers/#{repository.language}_linter".classify.constantize
    commit_data = github_client.fetch_last_commit(repository.github_id)
    linter_parser.build_data(scan_result).merge(commit_data)
  end
end
