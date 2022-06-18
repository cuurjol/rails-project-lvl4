# frozen_string_literal: true

class GithubClient
  LANGUAGES = Repository.language.values

  def initialize(user_id, access_token)
    @user_id = user_id
    @client = Octokit::Client.new(access_token: access_token)
  end

  def find_repo(github_id)
    repos.find { |repo| repo.id == github_id }
  end

  def client_repos
    repos_by_language.map { |repo| [repo.full_name, repo.id] }
  end

  def repos_by_language(*languages)
    languages = languages.presence || LANGUAGES
    repos.select { |repo| repo.language.present? && languages.include?(repo.language) }
  end

  private

  def repos
    Rails.cache.fetch([@user_id, :client_repositories], expires_in: 10.minutes) do
      @client.repos
    end
  end
end
