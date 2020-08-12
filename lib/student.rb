require 'pry'
require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def self.create_table
    sql = <<-SQL
    CREATE TABLE students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO students(name,grade) VALUES (?,?)
      SQL
      DB[:conn].execute(sql,self.name,self.grade)
      id_query= <<-SQL
      SELECT last_insert_rowid()
      FROM students
      SQL
      @id = DB[:conn].execute(id_query)[0][0]
      self
    end
  end

  def update
    sql = <<-SQL
    UPDATE students SET grade = ?, name = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.grade, self.name, self.id)
    
  end

  def self.create(name,grade)
    new_student = Student.new(name,grade)
    new_student.save
    new_student
  end

  def self.new_from_db(row)
    retrieved_student = Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL 
    SELECT *
    FROM students
    WHERE students.name = ?
    SQL
    found_record = DB[:conn].execute(sql, name).first
    Student.new_from_db(found_record)
  end
end
