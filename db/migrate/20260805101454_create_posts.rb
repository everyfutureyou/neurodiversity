class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :slug, null: false
      t.jsonb :title, null: false, default: {}
      t.jsonb :body, null: false, default: {}
      t.belongs_to :author, null: false, foreign_key: { to_table: :users }
      t.datetime :published_at

      t.timestamps
    end

    add_index :posts, :slug, unique: true
    add_index :posts, :published_at
  end
end
