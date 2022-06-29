# frozen_string_literal: true

class GithubClient
  LANGUAGE_FILTERS = Repository.language.values

  def initialize(user_id, access_token)
    @user_id = user_id
    @client = Octokit::Client.new(access_token: access_token, per_page: 100)
  end

  def find_repo(github_id)
    @client.repo(github_id)
  end

  def client_repos
    existing_user_repos = User.find(@user_id).repositories.pluck(:full_name)
    repos.select { |repo| repo.language.present? && LANGUAGE_FILTERS.include?(repo.language.downcase) }
         .reject { |repo| existing_user_repos.include?(repo.full_name) }
         .map { |repo| [repo.full_name, repo.id] }
  end

  def fetch_last_commit(github_id)
    commits = commits(github_id)
    { commit_url: commits.first['html_url'], commit_sha: commits.first['sha'] }
  end

  def create_hook(github_id)
    url = Rails.application.routes.url_helpers.api_checks_url
    config = { url: url, content_type: 'json' }
    options = { events: ['push'], active: true }
    @client.create_hook(github_id, 'web', config, options)
  end

  def remove_hook(github_id)
    url = Rails.application.routes.url_helpers.api_checks_url
    webhook = @client.hooks(github_id).find { |hook| hook.config.url == url }
    return false if webhook.blank?

    @client.remove_hook(github_id, webhook.id)
  end

  private

  def repos
    Rails.cache.fetch([@user_id, :client_repositories], expires_in: 5.minutes) do
      @client.repos
    end
  end

  def commits(github_id)
    Rails.cache.fetch([@user_id, :client_commits], expires_in: 5.minutes) do
      @client.commits(github_id)
    end
  end
end
