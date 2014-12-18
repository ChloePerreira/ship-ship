class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :weight
      t.string :length
      t.string :width
      t.string :height

      t.timestamps
    end
  end
end
