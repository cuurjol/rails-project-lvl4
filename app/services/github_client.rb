# frozen_string_literal: true

class GithubClient
  LANGUAGE_FILTERS = Repository.language.values

  def initialize(user_id, access_token)
    @user_id = user_id
    @client = Octokit::Client.new(access_token: access_token)
  end

  def find_repo(github_id)
    repos.find { |repo| repo.id == github_id }
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
