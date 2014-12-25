class AddShipOptionToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :shipoption, :string
  end
end
