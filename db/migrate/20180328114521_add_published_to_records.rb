class AddPublishedToRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :records, :published, :boolean
  end
end
