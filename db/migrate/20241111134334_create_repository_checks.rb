class CreateRepositoryChecks < ActiveRecord::Migration[7.2]
  def change
    create_table :repository_checks do |t|
      t.references :repository, null: false, foreign_key: true
      t.string :commit_id
      t.string :status
      t.text :result

      t.timestamps
    end
  end
end
