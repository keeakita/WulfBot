class CreatePointRecords < ActiveRecord::Migration
  def change
    create_table :point_records do |t|
      t.string  :user
      t.integer :group
      t.integer :upvotes, default: 0
      t.integer :downvotes, default: 0
    end
  end
end
