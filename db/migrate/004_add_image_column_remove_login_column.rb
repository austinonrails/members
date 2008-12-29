class AddImageColumnRemoveLoginColumn < ActiveRecord::Migration
  def self.up
    #add blob for images managed by file_column plugin
    add_column :members, :image, :string
    #remove login field, email is unique enough and we'll give members the option to hide it
    remove_column :members, :login
    #using file_column to handle images after this migration
    remove_column :members, :image_url
  end

  def self.down
    add_column :members, :login, :string, :null => false
    remove_column :members, :image
  end
end
