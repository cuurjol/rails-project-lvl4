# frozen_string_literal: true

module Parsers
  class RubyLinter
    class << self
      def build_data(text)
        json_hash = JSON.parse(text, symbolize_names: true)
        offenses_amount = json_hash[:summary][:offense_count]
        passed = offenses_amount.zero?
        offenses_files = build_files(json_hash[:files])
        { offenses_amount: offenses_amount, passed: passed, offenses_files: offenses_files }
      end

      private

      def build_files(files)
        files.select { |file| file[:offenses].present? }.map do |file_hash|
          file_path = file_hash[:path][Regexp.new("(?<=#{RepositoryManager::BASE_DIRECTORY}/).*")]
          offenses = build_offenses(file_hash[:offenses])
          offenses_count = offenses.count
          { file_path: file_path, offenses_count: offenses_count, offenses: offenses }
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
