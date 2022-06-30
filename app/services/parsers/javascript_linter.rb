# frozen_string_literal: true

module Parsers
  class JavascriptLinter
    class << self
      def build_data(text)
        json_hash = JSON.parse(text[/\[.*\]/], symbolize_names: true)
        offences_amount = json_hash.sum { |file| file[:errorCount] }
        passed = offences_amount.zero?
        offences_files = build_files(json_hash)
        { offences_amount: offences_amount, passed: passed, offences_files: offences_files }
      end

      private

      def build_files(files)
        files.select { |file| file[:messages].present? }.map do |file_hash|
          file_path = file_hash[:filePath][Regexp.new("(?<=#{RepositoryManager::BASE_DIRECTORY}/).*")]
          offenses = build_offences(file_hash[:messages])
          offenses_count = file_hash[:errorCount]
          { file_path: file_path, offenses_count: offenses_count, offenses: offenses }
        end
      end

      def build_offences(offences)
        offences.map do |offence|
          {
            rule: offence[:ruleId],
            message: offence[:message],
            line: offence[:line],
            column: offence[:column]
          }
        end
      end
    end
  end
end
