class AddStatusToInstruments < ActiveRecord::Migration[5.0]
  def change
    add_column :instruments, :status, :text
  end
end
