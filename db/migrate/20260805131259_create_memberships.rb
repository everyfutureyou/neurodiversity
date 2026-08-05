class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.string :stripe_subscription_id
      t.integer :status, null: false, default: 0
      t.integer :amount_cents, null: false, default: 0

      t.timestamps
    end
    add_index :memberships, :stripe_subscription_id, unique: true
  end
end
