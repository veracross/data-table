require 'spec_helper'

describe DataTable do
  let(:collection) {
      [
        {:name => 'Luke Skywalker', :class => 'Jedi Knight'},
        {:name => 'Emporer Palpatine', :class => 'Sith Lord'},
        {:name => 'Mithrander', :class => 'Wizard'},
        {:name => 'Aragorn', :class => 'Ranger'}
      ]
    }


  it "should render the collection" do
    html = DataTable.render(collection) do |t|
      t.column :name, 'Name'
      t.column :class, 'Class'
    end

    html.should eq(%{<table id='' class='data_table ' cellspacing='0' cellpadding='0'><caption></caption><thead><tr><th class='name ' >Name</th><th class='class ' >Class</th></tr></thead><tbody><tr class='row_0 ' ><td class='name text' >Luke Skywalker</td><td class='class text' >Jedi Knight</td></tr><tr class='row_1 alt ' ><td class='name text' >Emporer Palpatine</td><td class='class text' >Sith Lord</td></tr><tr class='row_2 ' ><td class='name text' >Mithrander</td><td class='class text' >Wizard</td></tr><tr class='row_3 alt ' ><td class='name text' >Aragorn</td><td class='class text' >Ranger</td></tr></tbody></table>})
  end
end
