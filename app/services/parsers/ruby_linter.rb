# frozen_string_literal: true

module Parsers
  class RubyLinter
    class << self
      def build_data(text)
        json_hash = JSON.parse(text, symbolize_names: true)
        offences_amount = json_hash[:summary][:offense_count]
        passed = offences_amount.zero?
        offences_files = build_files(json_hash[:files])
        { offences_amount: offences_amount, passed: passed, offences_files: offences_files }
      end

      private

      def build_files(files)
        files.select { |file| file[:offenses].present? }.map do |file_hash|
          file_path = file_hash[:path][Regexp.new("(?<=#{RepositoryManager::BASE_DIRECTORY}/).*")]
          offenses = build_offences(file_hash[:offenses])
          offenses_count = offenses.count
          { file_path: file_path, offenses_count: offenses_count, offenses: offenses }
        end
      end

      def build_offences(offences)
        offences.map do |offence|
          {
            rule: offence[:cop_name],
            message: offence[:message],
            line: offence[:location][:line],
            column: offence[:location][:column]
          }
        end
      end
    end
  end
end
