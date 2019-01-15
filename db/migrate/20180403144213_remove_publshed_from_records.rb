class RemovePublshedFromRecords < ActiveRecord::Migration[5.0]
  def change
    remove_column :records, :published, :boolean
  end
end
