class AddTestData < ActiveRecord::Migration
  def self.up
    execute "INSERT INTO `members` VALUES (2,'Annoying','foo','foo@foo.com','http://www.geocities.com/name_here44/ava.JPG','mo44','chopper',2,NULL);"
    execute "INSERT INTO `members` VALUES (7,'Damon','Clinkscales','scales@pobox.com','http://static.flickr.com/6/buddyicons/77731171@N00.jpg?1129704910','damon','damon',2,'http://www.damonclinkscales.com/');"
    execute "INSERT INTO `members` VALUES (8,'Manton','Reece','manton@manton.org','http://www.manton.org/images/2006/rails_backroom.jpg','manton','manton',NULL,'http://www.manton.org');"
    execute "INSERT INTO `occupations` VALUES (1,'Designer');"
    execute "INSERT INTO `occupations` VALUES (2,'Manager');"
    execute "INSERT INTO `occupations` VALUES (3,'Developer');"
  end

  def self.down
    execute "DELETE FROM `members`;"
    execute "DELETE FROM `occupations`;"
  end
end
