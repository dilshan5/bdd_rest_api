class Employee
  attr_accessor :emp_name, :emp_salary, :emp_age, :emp_id

  def initialize(name, salary, age)
    @emp_name = name
    @emp_salary = salary
    @emp_age = age
    @emp_id
  end

  # convert employee object to json
  def as_json(options={})
    {
        name: @emp_name,
        salary: @emp_salary,
        age: @emp_age
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end

end