# frozen_string_literal: true

class CreateGithubWebhookJob < ApplicationJob
  queue_as :default

  def perform(repository_id)
    repository = Repository.find(repository_id)
    user = repository.user
    GithubClient.new(user.id, user.token).create_hook(repository.github_id)
  end
end
