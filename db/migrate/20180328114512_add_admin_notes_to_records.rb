class AddAdminNotesToRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :records, :admin_notes, :text
  end
end
