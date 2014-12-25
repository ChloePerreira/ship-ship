class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :option

      t.timestamps
    end
  end
end
