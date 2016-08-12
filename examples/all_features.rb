require 'byebug'
require 'pry'
require 'pry-byebug'
require 'data-table'

assignments = [
  {assignment_type: "Homework", description: "hw1", score: 98, course: "Math", school: "Yale"},
  {assignment_type: "Test", description: "test 1", score: 89, course: "Math", school: "Yale"},
  {assignment_type: "Quiz", description: "quiz 1", score: 89, course: "Biology", school: "Yale"},
  {assignment_type: "Test", description: "test 2", score: 89, course: "Biology", school: "Yale"},
  {assignment_type: "Homework", description: "hw2", score: 90, course: "History", school: "Harvard"},
  {assignment_type: "Test", description: "test 1", score: 75, course: "History", school: "Harvard"},
  {assignment_type: "Homework", description: "hw3", score: 90, course: "Law", school: "Harvard"},
  {assignment_type: "Quiz", description: "quiz 1", score: 90, course: "Law", school: "Harvard"}
]

@assignments_table = DataTable.render(assignments) do |t|

  t.id = 'assignments'
  t.title = "Table Title"
  # t.repeat_headers_for_groups = true
  t.column :assignment_type, "Assignment Type"
  t.column :description, "Description"
  t.column :score, "Score"
  t.column :course, "Course"
  t.column :school, "School"

  # Multiple levels of grouping
  t.group_by :school, index: 0
  t.group_by :course, index: 1

  # Multiple subtotals
  t.subtotal :score, :avg, index: 1 do |result|
    "Average: #{result}"
  end

  t.subtotal :score, :max, index: 0 do |result|
    "Max: #{result}"
  end

  # Multiple totals
  t.total :score, :max, index: 1

  # Multiple totals with custom totaling
  t.total(:score, :avg, index: 2) do |average|
    "#{average / 100.0}%"
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
