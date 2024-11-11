class Repository < ApplicationRecord
  extend Enumerize

  belongs_to :user

  enumerize :language, in: %w[Ruby], predicates: true, scope: true

  validates :name, :github_id, :full_name, :clone_url, :ssh_url, presence: true
  validates :language, inclusion: { in: Repository.language.values }
  validates :github_id, uniqueness: true
end
