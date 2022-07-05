# frozen_string_literal: true

module Parsers
  class JavascriptLinter
    class << self
      def build_data(text)
        json_hash = JSON.parse(text, symbolize_names: true)
        passed = json_hash.sum { |file_hash| file_hash[:errorCount] }.zero?
        offense_files = build_offense_files(json_hash)
        { passed: passed, offense_files: offense_files }
      end

      private

      def build_offense_files(json_hash)
        json_hash.select { |file_hash| file_hash[:messages].present? }.map do |file_hash|
          file_path = file_hash[:filePath][Regexp.new("(?<=#{RepositoryManager::BASE_DIRECTORY}/).*")]
          offenses = build_offenses(file_hash[:messages])
          offense_count = file_hash[:errorCount]
          { file_path: file_path, offense_count: offense_count, offenses: offenses }
        end
      end

      def build_offenses(offenses)
        offenses.map do |offense|
          {
            rule: offense[:ruleId],
            message: offense[:message],
            line: offense[:line],
            column: offense[:column]
          }
        end
      end
    end
  end
end
