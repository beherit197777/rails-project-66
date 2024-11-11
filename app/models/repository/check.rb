require 'aasm'

class Repository::Check < ApplicationRecord
  include AASM

  belongs_to :repository

  aasm column: 'status' do
    state :pending, initial: true
    state :running
    state :completed
    state :failed

    event :run do
      transitions from: :pending, to: :running
    end

    event :complete do
      transitions from: :running, to: :completed
    end

    event :fail do
      transitions from: :running, to: :failed
    end
  end
end
