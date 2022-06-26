# frozen_string_literal: true

class BashCommand
  class << self
    def run(command)
      stdout, stderr, status = Open3.capture3(command)
      raise(StandardError, stderr) if status.exitstatus > 1

      stdout
    end
  end
end
