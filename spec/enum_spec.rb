require 'spec_helper'

describe Enumerable do
  context "with a non-empty collection of hashes" do
    let(:collection) {
      [
        {name: 'Luke Skywalker', class: 'Jedi Knight', world: 'Star Wars', power_level: 50},
        {name: 'Emporer Palpatine', class: 'Sith Lord', world: 'Star Wars', power_level: 95},
        {name: 'Mithrander', class: 'Wizard', world: 'Middle Earth', power_level: 9001},
        {name: 'Aragorn', class: 'Ranger', world: 'Middle Earth', power_level: 80}
      ]
    }

    let(:groupings) { [:class] }

    it "should transform a collection into nested hash based on and array of groups" do
      expect(
        collection.group_by_recursive(groupings)
      ).to eq(
        {
          "Jedi Knight"=>[{:name=>"Luke Skywalker", :class=>"Jedi Knight", :world=>"Star Wars", :power_level=>50}],
          "Sith Lord"=>[{:name=>"Emporer Palpatine", :class=>"Sith Lord", :world=>"Star Wars", :power_level=>95}],
          "Wizard"=>[{:name=>"Mithrander", :class=>"Wizard", :world=>"Middle Earth", :power_level=>9001}],
          "Ranger"=>[{:name=>"Aragorn", :class=>"Ranger", :world=>"Middle Earth", :power_level=>80}]
        }
      )
    end

    it "should traverse a nested hash" do
      grouped_collection = collection.group_by_recursive(groupings)
      ungrouped = []
      grouped_collection.each_pair_recursive { |_k, v| ungrouped.concat(v) }
      expect(ungrouped).to eq(collection)
    end
  end
end
