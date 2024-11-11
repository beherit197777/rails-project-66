class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :nickname
      t.string :token
      t.string :name
      t.string :image_url

      t.timestamps
    end
  end
end
