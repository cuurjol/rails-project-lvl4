# frozen_string_literal: true

module Parsers
  class JavascriptLinter
    class << self
      def build_data(text)
        json_hash = JSON.parse(text, symbolize_names: true)
        offenses_amount = json_hash.sum { |file| file[:errorCount] }
        passed = offenses_amount.zero?
        offenses_files = build_files(json_hash)
        { offenses_amount: offenses_amount, passed: passed, offenses_files: offenses_files }
      end

      private

      def build_files(files)
        files.select { |file| file[:messages].present? }.map do |file_hash|
          file_path = file_hash[:filePath][Regexp.new("(?<=#{RepositoryManager::BASE_DIRECTORY}/).*")]
          offenses = build_offenses(file_hash[:messages])
          offenses_count = file_hash[:errorCount]
          { file_path: file_path, offenses_count: offenses_count, offenses: offenses }
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
