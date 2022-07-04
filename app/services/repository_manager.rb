# frozen_string_literal: true

class RepositoryManager
  BASE_DIRECTORY = 'tmp/github_repositories'
  LINTERS = {
    javascript: { utility_command: 'node_modules/eslint/bin/eslint.js', config: '.eslintrc.yml' },
    ruby: { utility_command: 'bundle exec rubocop', config: '.rubocop.yml' }
  }.freeze

  class << self
    def clone_repository(repository)
      BashCommand.run("git clone #{repository.clone_url} #{directory_path(repository)}")
    end

    def scan_repository(repository)
      language = repository.language.to_sym
      files = directory_path(repository)
      utility_command, config = LINTERS[language].values
      BashCommand.run("#{utility_command} #{files} --format json --config #{config}")
    end

    def remove_repository(repository)
      BashCommand.run("rm -rf #{directory_path(repository)}")
    end

    private

    def directory_path(repository)
      Rails.root.join("#{BASE_DIRECTORY}/#{repository.full_name}")
    end
  end
end
