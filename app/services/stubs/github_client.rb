# frozen_string_literal: true

module Stubs
  class GithubClient
    def initialize(_access_token); end # rubocop:disable

    def find_repo(_github_id)
      file_path = Rails.root.join('test/fixtures/files/found_github_repository.json')
      deserialize_to_struct(build_hash(file_path))
    end

    def client_repos(_user_id)
      file_path = Rails.root.join('test/fixtures/files/github_repositories.json')
      build_hash(file_path).map { |repo| deserialize_to_struct(repo) }.map { |repo| [repo.full_name, repo.id] }
    end

    def fetch_last_commit(_github_id)
      { commit_url: Faker::Internet.url, commit_sha: Faker::Crypto.sha1 }
    end

    def create_hook(_github_id, _api_url); end

    def remove_hook(_github_id, _api_url); end

    private

    def build_hash(file_path)
      JSON.parse(File.read(file_path), symbolize_names: true)
    end

    def deserialize_to_struct(hash)
      struct = Struct.new(*hash.keys.map(&:to_sym))
      construct = hash.values.map do |value|
        case value
        when Hash
          deserialize_to_struct(value)
        when Array
          value.map { |elem| elem.is_a?(Hash) ? deserialize_to_struct(elem) : elem }
        else
          value
        end
      end
      struct.new(*construct)
    end
  end
end
