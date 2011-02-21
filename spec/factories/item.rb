Factory.define :item do |i|
  i.hnid 10
  i.association :parent, :factory => :parent
  i.contents "item"
end

Factory.define :parent, :class => 'item' do |i|
  i.hnid 6
  i.association :parent, :factory => :grandparent
  i.contents "parent"
end

Factory.define :grandparent, :class => 'item' do |i|
  i.hnid 2
  i.contents "frist post!!1"
end

Factory.define :uncle, :class => 'item' do |i|
  i.hnid 5
  i.association :parent, :factory => :grandparent
  i.contents "uncle"
end
