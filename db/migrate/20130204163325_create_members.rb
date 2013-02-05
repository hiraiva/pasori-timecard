class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :idm
      t.string :name
      t.datetime :created_at

      t.timestamps
    end

    add_index :members, :idm, :unique => true
  end

end
