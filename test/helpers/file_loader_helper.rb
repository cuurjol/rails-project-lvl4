# frozen_string_literal: true

module FileLoaderHelper
  def load_fixture(filename)
    File.read(Rails.root.join("test/fixtures/#{filename}"))
  end
end
