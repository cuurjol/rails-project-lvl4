# frozen_string_literal: true

class CreateGithubWebhookJob < ApplicationJob
  queue_as :default

  def perform(github_id, user_id)
    ApplicationContainer[:github_client].new(user_id, User.find(user_id).token).create_hook(github_id)
  end
end
