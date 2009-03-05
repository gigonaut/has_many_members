class HasManyMembersMigration < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.integer :member_id
      t.integer :joinable_id
      t.string :joinable_type
      t.datetime :joined_on
      t.integer :role_id
      t.string :member_type
      t.string :status, :default => "active"
      t.boolean :default_membership, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :memberships
  end
end
