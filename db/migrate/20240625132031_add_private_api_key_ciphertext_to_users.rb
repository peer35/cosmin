class AddPrivateApiKeyCiphertextToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :private_api_key_ciphertext, :text
  end
end
