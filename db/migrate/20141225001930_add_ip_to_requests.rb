class AddIpToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :ip, :string
  end
end
