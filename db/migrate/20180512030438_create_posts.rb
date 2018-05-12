class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.text :content
      t.string :picture
      t.string :kind

      t.timestamps
    end
  end
end
