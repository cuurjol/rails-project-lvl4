# frozen_string_literal: true

module Stubs
  class RepositoryManager
    class << self
      def clone_repository(_repository); end

      def scan_repository(repository)
        File.read(Rails.root.join("test/fixtures/files/#{repository.language}_scan_repository.json"))
      end

      def remove_repository(_repository); end
    end
  end
end
