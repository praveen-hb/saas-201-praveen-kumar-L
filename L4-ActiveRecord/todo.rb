require "active_record"

class Todo < ActiveRecord::Base
  def self.add_task(todo)
    create(todo_text: todo[:todo_text], due_date: Date.today + todo[:due_in_days], completed: false)
  end

  def self.overdue
    where("due_date < ?", Date.today)
  end

  def self.due_today
    where("due_date = ?", Date.today)
  end

  def self.due_later
    where("due_date > ?", Date.today)
  end

  def to_displayable_string
    display_status = completed ? "[X]" : "[ ]"
    display_date = due_date == Date.today ? nil : due_date
    "#{id}. #{display_status} #{todo_text} #{display_date}"
  end

  def self.show_list
    puts "My Todo-list\n\n"

    puts "Overdue\n"
    puts overdue.order(:id).map { |todo| todo.to_displayable_string }
    puts "\n\n"

    puts "Due Today\n"
    puts due_today.order(:id).map { |todo| todo.to_displayable_string }
    puts "\n\n"

    puts "Due Later\n"
    puts due_later.order(:id).map { |todo| todo.to_displayable_string }
    puts "\n\n"
  end

  def self.mark_as_complete!(todo_id)
    todo = find(todo_id)
    todo.update(completed: true)
    todo
  end
end
