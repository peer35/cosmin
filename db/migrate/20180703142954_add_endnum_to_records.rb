class AddEndnumToRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :records, :endnum, :integer
  end
end
