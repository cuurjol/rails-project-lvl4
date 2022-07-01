# frozen_string_literal: true

class RemoveGithubWebhookJob < ApplicationJob
  queue_as :default

  def perform(github_id, user_id)
    ApplicationContainer[:github_client].new(user_id, User.find(user_id).token).remove_hook(github_id)
  end
end
