# frozen_string_literal: true

class Repository < ApplicationRecord
  extend Enumerize
  enumerize :language, in: %w[ruby javascript]

  belongs_to :user
  has_many :checks, class_name: 'Repository::Check', dependent: :destroy

  validates :github_id, presence: true, uniqueness: true
end
