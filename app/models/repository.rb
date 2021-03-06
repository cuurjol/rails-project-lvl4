# frozen_string_literal: true

class Repository < ApplicationRecord
  extend Enumerize
  enumerize :language, in: %w[ruby javascript]

  include AASM

  aasm do
    state :fetching, initial: true
    state :finished, :failure

    event :fetch do
      transitions from: %i[fetching finished failure], to: :fetching
    end

    event :finish do
      transitions from: :fetching, to: :finished
    end

    event :fail do
      transitions from: :fetching, to: :failure
    end
  end

  belongs_to :user
  has_many :checks, class_name: 'Repository::Check', dependent: :destroy

  validates :github_id, presence: true, uniqueness: true
end
