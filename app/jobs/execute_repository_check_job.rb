# frozen_string_literal: true

class ExecuteRepositoryCheckJob < ApplicationJob
  queue_as :default

  def perform(check_id)
    check = Repository::Check.find(check_id)

    begin
      start_process(check)
    rescue StandardError => e
      Rails.logger.debug(e.full_message)
      check.reject!
    ensure
      RepositoryManager.remove_repository(check.repository)
    end
  end

  private

  def start_process(check)
    check.start!
    check.update(check_params(check.repository))
    check.finish!
  end

  def check_params(repository)
    RepositoryManager.clone_repository(repository)
    scan_result = RepositoryManager.scan_repository(repository)
    github_client = GithubClient.new(repository.user.id, repository.user.token)
    linter_parser = "parsers/#{repository.language}_linter".classify.constantize
    commit_data = github_client.fetch_last_commit(repository.github_id)
    linter_parser.build_data(scan_result).merge(commit_data)
  end
end
