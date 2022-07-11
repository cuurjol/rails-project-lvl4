# frozen_string_literal: true

class UpdateRepositoryInfoJob < ApplicationJob
  queue_as :default

  def perform(repository_id)
    repository = Repository.find(repository_id)
    start_process(repository)
  rescue StandardError => e
    Rails.logger.debug(e.full_message)
    repository.fail!
  end

  private

  def start_process(repository)
    repository.fetch!
    repository.update!(repository_params(repository.github_id, repository.user))
    repository.finish!
  end

  def repository_params(github_id, user)
    repo = ApplicationContainer[:github_client].new(user.token).find_repo(github_id)

    { name: repo.name, full_name: repo.full_name, description: repo.description, language: repo.language.downcase,
      html_url: repo.html_url, github_created_at: repo.created_at, github_updated_at: repo.updated_at,
      clone_url: repo.clone_url }
  end
end
