# frozen_string_literal: true

module Parsers
  class RubyLinter
    class << self
      def build_data(text)
        json_hash = JSON.parse(text, symbolize_names: true)
        offense_count = json_hash[:summary][:offense_count]
        passed = offense_count.zero?
        offense_files = build_offense_files(json_hash)
        { offense_count: offense_count, passed: passed, offense_files: offense_files }
      end

      private

      def build_offense_files(json_hash)
        json_hash[:files].select { |file_hash| file_hash[:offenses].present? }.map do |file_hash|
          file_path = file_hash[:path][Regexp.new("(?<=#{RepositoryManager::BASE_DIRECTORY}/).*")]
          offenses = build_offenses(file_hash[:offenses])
          offense_count = offenses.count
          { file_path: file_path, offense_count: offense_count, offenses: offenses }
        end
      end

      def build_offenses(offenses)
        offenses.map do |offense|
          {
            rule: offense[:cop_name],
            message: offense[:message],
            line: offense[:location][:line],
            column: offense[:location][:column]
          }
        end
      end
    end
  end
end
