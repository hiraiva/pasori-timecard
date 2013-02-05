class CreateMemberTimes < ActiveRecord::Migration
  def change
    create_table :member_times do |t|
      t.integer :member_id
      t.integer :kind
      t.datetime :created_at

      t.timestamps
    end

    add_index :member_times, [:member_id, :created_at]
    add_index :member_times, [:member_id, :kind, :created_at]
  end
end
