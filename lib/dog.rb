require_relative "../config/environment.rb"

class Dog

  attr_accessor :name, :breed, :id

  def self.db_execute(sql)
    DB[:conn].execute(sql)
  end

  def initialize(dog)
    @name = dog[:name]
    @breed = dog[:breed]
    @id = dog[:id] ? dog[:id] : nil
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );

    SQL
    self.db_execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL
    self.db_execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?,?);
    SQL
    DB[:conn].execute(sql,self.name,self.breed)

    sql = <<-SQL
      SELECT last_insert_rowid() FROM dogs;
    SQL

    self.id = DB[:conn].execute(sql)[0][0]
    self
  end

  def self.create(dog)
    new_dog = self.new(dog)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?;
    SQL
    self.new_from_db(DB[:conn].execute(sql,id)[0])
  end

  def self.find_or_create_by(dog)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL
    row = DB[:conn].execute(sql,dog[:name],dog[:breed])
    if !row.empty?
      new_dog = self.new_from_db(row[0])
    else
      new_dog = self.create(dog)
    end
    new_dog
  end

  def self.new_from_db(row)
    new_dog = Dog.new({})
    new_dog.id = row[0]
    new_dog.name = row[1]
    new_dog.breed = row[2]
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?;
    SQL
    self.new_from_db(DB[:conn].execute(sql,name)[0])
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
    SQL
    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end

end
