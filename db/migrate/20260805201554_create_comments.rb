class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.bigint :parent_id
      t.text :body, null: false

      t.timestamps
    end

    add_index :comments, :parent_id
  end
end
