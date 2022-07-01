# frozen_string_literal: true

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register(:github_client, -> { Stubs::GithubClient })
    register(:repository_manager, -> { Stubs::RepositoryManager })
  else
    register(:github_client, -> { GithubClient })
    register(:repository_manager, -> { RepositoryManager })
  end
end
