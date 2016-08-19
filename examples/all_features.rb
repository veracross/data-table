require 'byebug'
require 'pry'
require 'pry-byebug'
require 'data-table'

assignments = [
  {assignment_type: "Homework", karma: 10, description: "hw1", score: 98, points: 2, course: "Math", school: "Yale"},
  {assignment_type: "Test", karma: 15, description: "test 1", score: 89, points: 2, course: "Math", school: "Yale"},
  {assignment_type: "Quiz", karma: 7, description: "quiz 1", score: 89, points: 2, course: "Biology", school: "Yale"},
  {assignment_type: "Test", karma: 10, description: "test 2", score: 89, points: 2, course: "Biology", school: "Yale"},
  {assignment_type: "Homework", karma: 13, description: "hw2", score: 99, points: 2, course: "History", school: "Yale"},
  {assignment_type: "Test", karma: 20, description: "test 1", score: 71, points: 2, course: "History", school: "Yale"},
  {assignment_type: "Homework", karma: 25, description: "hw3", score: 93, points: 2, course: "Law", school: "Yale"},
  {assignment_type: "Quiz", karma: 18, description: "quiz 1", score: 91, points: 2, course: "Law", school: "Yale"},
  {assignment_type: "Homework", karma: 13, description: "hw2", score: 90, points: 2, course: "History", school: "Harvard"},
  {assignment_type: "Test", karma: 20, description: "test 1", score: 75, points: 2, course: "History", school: "Harvard"},
  {assignment_type: "Homework", karma: 25, description: "hw3", score: 90, points: 2, course: "Law", school: "Harvard"},
  {assignment_type: "Quiz", karma: 18, description: "quiz 1", score: 90, points: 2, course: "Law", school: "Harvard"},
  {assignment_type: "Homework", karma: 10, description: "hw1", score: 62, points: 2, course: "Math", school: "Harvard"},
  {assignment_type: "Test", karma: 15, description: "test 1", score: 53, points: 2, course: "Math", school: "Harvard"},
  {assignment_type: "Quiz", karma: 7, description: "quiz 1", score: 75, points: 2, course: "Biology", school: "Harvard"},
  {assignment_type: "Test", karma: 10, description: "test 2", score: 32, points: 2, course: "Biology", school: "Harvard"}
]

@assignments_table = DataTable.render(assignments) do |t|

  t.id = 'assignments'
  t.title = "Table Title"
  # t.repeat_headers_for_groups = true
  t.column :assignment_type, "Assignment Type"
  t.column :description, "Description"
  t.column :score, "Score"
  t.column :points, "Points"
  t.column :course, "Course"
  t.column :school, "School"
  t.column :karma, "Karma"

  # Multiple levels of grouping
  t.group_by :school, level: 1
  t.group_by :course, level: 2
  t.group_by :assignment_type, level: 3

  # Multiple totals
  t.total :score, 0, :max do |result|
    "Total score max: #{result}"
  end

  t.total :points, 0, :max do |result|
    "Total score max: #{result}"
  end

  t.total :karma, 0, :max do |result|
    "Total score max: #{result}"
  end

  t.total :score, 1, :avg do |result|
    "Total score avg: #{result}"
  end

  t.total :karma, 1, :avg do |average|

  end

  # Multiple subtotals
  t.subtotal :score, 0, :avg do |result|
    "Score Avg #{result}"
  end

  t.subtotal :points, 0, :avg do |result|
    "Points Avg #{result}"
  end

  t.subtotal :karma, 0, :avg do |result|
    "Karma Avg #{result}"
  end

  t.subtotal :score, 1, :max do |result|
    "Score Max #{result}"
  end

  t.subtotal :karma, 1, :max do |result|
    "Karma Max#{result}"
  end

  t.subtotal :points, 1, :max do |result|
    "Points Max #{result}"
  end

  t.subtotal :score, 2, :sum do |result|
    "Score Sum #{result}"
  end

  t.subtotal :karma, 2, :sum do |result|
    "Karma Avg #{result}"
  end

  t.subtotal :points, 3 do |result|
    "Points custom"
  end
end

@assignments_markup = <<-HTML_DOC
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Data Tables Example</title>
    <style>
      table {
        border-collapse: collapse;
      }
      th, td {
          border: 1px solid black;
          padding: 10px 15px;
      }
      .data_table {width: 100%; empty-cells: show}
      .data_table td, .data_table th {padding: 3px}

      .data_table caption {font-size: 2em; font-weight: bold}

      .data_table thead {}
      .data_table thead th {background-color: #ddd; border-bottom: 1px solid #bbb;}

      .data_table tbody {}
      .data_table tbody tr.alt {background-color: #eee;}

      .data_table .group_header th {text-align: left;}

      .data_table .subtotal {}
      .data_table .subtotal td {border-top: 1px solid #000;}

      .data_table tfoot {}
      .data_table tfoot td {border-top: 1px solid #000;}

      .empty_data_table {text-align: center; background-color: #ffc;}

      /* Data Types */
      .data_table .number, .data_table .money {text-align: right}
      .data_table .text {text-align: left}

      [class^="level_"] {
        text-align: left
      }
      .level_0 th {
        padding-left: 0;
      }
      .level_1 th {
        padding-left: 35px;
      }
      .level_2 th {
        padding-left: 70px;
      }
    </style>
  </head>
  <body>
    #{@assignments_table}
  </body>
</html>
HTML_DOC

File.open("assigments_table.html", "w") { |f| f.write @assignments_markup }
