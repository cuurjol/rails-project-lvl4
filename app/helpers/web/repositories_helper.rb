# frozen_string_literal: true

module Web
  module RepositoriesHelper
    def client_repos
      GithubClient.new(current_user.id, current_user.token).client_repos
    end
  end
end
