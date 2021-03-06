require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Dot" do # :nodoc:
  
  DG_DOT = <<-DOT
digraph  {
    label = "Datacenters"
    Miranda [
        color = green,
        style = filled,
        label = "Miranda"
    ]

    Miranda -> Hillview [

    ]

    Miranda -> "San Francisco" [

    ]

    Miranda -> "San Jose" [

    ]

    Sunnyvale -> Miranda [

    ]

}
DOT
  
  before do
    @dg = DOT::DOTDigraph.new('label' => 'Datacenters')
    @dg << DOT::DOTNode.new('name' => 'Miranda', 'color' => 'green', 'style' => 'filled')
    @dg << DOT::DOTDirectedArc.new('from' => 'Miranda', 'to' => 'Hillview')
    @dg << DOT::DOTDirectedArc.new('from' => 'Miranda', 'to' => '"San Francisco"')
    @dg << DOT::DOTDirectedArc.new('from' => 'Miranda', 'to' => '"San Jose"')
    @dg << DOT::DOTDirectedArc.new('from' => 'Sunnyvale', 'to' => 'Miranda')
  end
  
  describe "generation" do
    it do
      @dg.to_s.should == DG_DOT
    end
  end
  
end
