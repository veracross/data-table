puts "Removing old gem file"
`rm data-table*.gem`

puts "Building new data-table gem"
`gem build ./data-table.gemspec`

puts "Uninstalling old data-table gem"
`gem uninstall -a data-table`

puts "Installing new build of data-table gem"
`gem install ./data-table*.gem`
