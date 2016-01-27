class ChangeGroupIntType < ActiveRecord::Migration
  def up
    change_column :point_records, :group, :integer, limit: 8
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
