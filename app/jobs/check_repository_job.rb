# frozen_string_literal: true

class CheckRepositoryJob < ApplicationJob
  queue_as :default

  def perform(check_id)
    check = Repository::Check.find(check_id)
    return unless check.created?

    CheckRepositoryService.new(check).perform
  end
end
