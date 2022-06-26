# frozen_string_literal: true

class LinterExecutor
  CONFIG_FILES = { ruby: '.rubocop.yml', javascript: '.eslintrc.yml' }.freeze
  COMMANDS = { ruby: 'bundle exec rubocop', javascript: 'yarn run eslint' }.freeze

  class << self
    def run(language, files: nil, options: nil)
      language = language.to_sym
      files = Array(files).join(' ')
      options = options_conversion(options)
      BashCommand.run("#{COMMANDS[language]} #{files} #{options}")
    end

    private

    def options_conversion(options)
      return options if options.is_a?(String)
      return '' unless options.is_a?(Hash)

      options.map { |key, value| "--#{key} #{value}" }.join(' ')
    end
  end
end
