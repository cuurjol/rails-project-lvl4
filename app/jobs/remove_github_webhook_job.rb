# frozen_string_literal: true

class RemoveGithubWebhookJob < ApplicationJob
  queue_as :default

  def perform(github_id, user_id)
    api_url = Rails.application.routes.url_helpers.api_checks_url
    access_token = User.find(user_id).token
    ApplicationContainer[:github_client].new(access_token).remove_hook(github_id, api_url)
  end
end
