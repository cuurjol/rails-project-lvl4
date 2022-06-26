# frozen_string_literal: true

class RepositoryManager
  BASE_DIRECTORY = 'tmp/github_repositories'

  class << self
    def clone_repository(repository)
      BashCommand.run("git clone #{repository.clone_url} #{directory_path(repository)}")
    end

    def scan_repository(repository)
      language = repository.language.to_sym
      files = directory_path(repository)
      options = { format: 'json', config: LinterExecutor::CONFIG_FILES[language] }
      LinterExecutor.run(language, files: files, options: options)
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
