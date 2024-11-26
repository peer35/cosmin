class AddProqolidIdToInstruments < ActiveRecord::Migration[6.1]
  def change
    add_column :instruments, :proqolid_id, :integer
  end
end
