class AddStatusToRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :records, :status, :text
  end
end
