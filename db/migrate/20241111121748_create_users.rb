class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :nickname
      t.string :token
      t.string :provider
      t.string :uid

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end