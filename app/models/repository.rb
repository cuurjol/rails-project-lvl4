# frozen_string_literal: true

class Repository < ApplicationRecord
  extend Enumerize
  enumerize :language, in: %w[Ruby Javascript]

  belongs_to :user

  validates :github_id, presence: true, uniqueness: true
end
