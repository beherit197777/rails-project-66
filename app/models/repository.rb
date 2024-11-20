class Repository < ApplicationRecord
  # extend Enumerize

  belongs_to :user
  has_many :checks, dependent: :destroy

  # enumerize :language, in: %i[javascript ruby], predicates: true, scope: true

  validates :name, presence: true
  # validates :language, inclusion: { in: Repository.language.values }
  validates :github_id, uniqueness: true
end
