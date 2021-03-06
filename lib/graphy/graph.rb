module Graphy

  # Using the functions required by the GraphAPI, it implements all the
  # basic functions of a Graph class by using only functions in GraphAPI.
  # An actual implementation still needs to be done, as in Digraph or
  # UndirectedGraph.
  class Graph
    include Enumerable
    include Labels

    def self.[](*a) self.new.from_array(*a); end

    def initialize(*params)
      raise ArgumentError if params.any? do |p|
       !(p.kind_of? Graphy::Graph or p.kind_of? Array or p.kind_of? Hash)
      end
      args = params.last || {}
      class << self
        self
      end.class_eval do
        include( args[:implementation]       ? args[:implementation]       : AdjacencyGraph )
        include( args[:algorithmic_category] ? args[:algorithmic_category] : Digraph        )
        include GraphAPI
      end
      implementation_initialize(*params)
    end

    # Shortcut for creating a Graph
    #
    #  Example: Graphy::Graph[1,2, 2,3, 2,4, 4,5].edges.to_a.to_s =>
    #    "(1-2)(2-3)(2-4)(4-5)"
    #
    # Or as a Hash for specifying lables
    # Graphy::Graph[ [:a,:b] => 3, [:b,:c] => 4 ]  (Note: Do not use for Multi or Pseudo graphs)
    def from_array(*a)
      if a.size == 1 and a[0].kind_of? Hash
        # Convert to edge class
        a[0].each do |k,v|
#FIXME, edge class shouldn't be assume here!!!
          if edge_class.include? Graphy::ArcNumber
            add_edge!(edge_class[k[0],k[1],nil,v])
          else
            add_edge!(edge_class[k[0],k[1],v])
          end
        end
#FIXME, edge class shouldn't be assume here!!!
      elsif a[0].kind_of? Graphy::Arc
        a.each{|e| add_edge!(e); self[e] = e.label}
      elsif a.size % 2 == 0
        0.step(a.size-1, 2) {|i| add_edge!(a[i], a[i+1])}
      else
        raise ArgumentError
      end
      self
    end

    # Non destructive version of add_vertex!, returns modified copy of Graph
    def add_vertex(v, l=nil) x=self.class.new(self); x.add_vertex!(v,l); end

    # Non destructive version add_edge!, returns modified copy of Graph
    def add_edge(u, v=nil, l=nil) x=self.class.new(self); x.add_edge!(u,v,l); end
    alias add_arc add_edge

    # Non destructive version of remove_vertex!, returns modified copy of Graph
    def remove_vertex(v) x=self.class.new(self); x.remove_vertex!(v); end

    # Non destructive version of remove_edge!, returns modified copy of Graph
    def remove_edge(u,v=nil) x=self.class.new(self); x.remove_edge!(u,v); end
    alias remove_arc remove_edge

    # Return Array of adjacent portions of the Graph
    #  x can either be a vertex an edge.
    #  options specifies parameters about the adjacency search
    #   :type can be either :edges or :vertices (default).
    #   :direction can be :in, :out(default) or :all.
    #
    # Note: It is probably more efficently done in the implementation class.
    def adjacent(x, options={})
      d = directed? ? (options[:direction] || :out) : :all

      # Discharge the easy ones first
      return [x.source] if x.kind_of? Arc and options[:type] == :vertices and d == :in
      return [x.target] if x.kind_of? Arc and options[:type] == :vertices and d == :out
      return [x.source, x.target] if x.kind_of? Arc and options[:type] != :edges and d == :all

      (options[:type] == :edges ? edges : to_a).select {|u| adjacent?(x,u,d)}
    end
#FIXME, THIS IS A HACK AROUND A SERIOUS PROBLEM
    alias graph_adjacent adjacent


    # Add all objects in _a_ to the vertex set.
    def add_vertices!(*a) a.each {|v| add_vertex! v}; self; end

    # See add_vertices!

    def add_vertices(*a) x=self.class.new(self); x.add_vertices(*a); self; end

    # Add all edges in the _edges_ Enumerable to the edge set.  Elements of the
    # Enumerable can be both two-element arrays or instances of DirectedArc or
    # UnDirectedArc.
    def add_edges!(*args) args.each { |edge| add_edge!(edge) }; self; end
    alias add_arcs! add_edges!

    # See add_edge!
    def add_edges(*a) x=self.class.new(self); x.add_edges!(*a); self; end
    alias add_arcs add_edges

    # Remove all vertices specified by the Enumerable a from the graph by
    # calling remove_vertex!.
    def remove_vertices!(*a) a.each { |v| remove_vertex! v }; end

    # See remove_vertices!
    def remove_vertices(*a) x=self.class.new(self); x.remove_vertices(*a); end

    # Remove all vertices edges by the Enumerable a from the graph by
    # calling remove_edge!
    def remove_edges!(*a) a.each { |e| remove_edges! e }; end
    alias remove_arcs! remove_edges!

    # See remove_edges
    def remove_edges(*a) x=self.class.new(self); x.remove_edges(*a); end
    alias remove_arcs remove_edges

    # Execute given block for each vertex, provides for methods in Enumerable
    def each(&block) vertices.each(&block); end

    # Returns true if _v_ is a vertex of the graph.
    # This is a default implementation that is of O(n) average complexity.
    # If a subclass uses a hash to store vertices, then this can be
    # made into an O(1) average complexity operation.
    def vertex?(v) vertices.include?(v); end

    # Returns true if u or (u,v) is an Arc of the graph.
    def edge?(*arg) edges.include?(edge_convert(*args)); end
    alias arc? edge?

    # Tests two objects to see if they are adjacent.
    # direction parameter specifies direction of adjacency, :in, :out, or :all(default)
    # All denotes that if there is any adjacency, then it will return true.
    # Note that the default is different than adjacent where one is primarily concerned with finding
    # all adjacent objects in a graph to a given object. Here the concern is primarily on seeing
    # if two objects touch. For vertexes, any edge between the two will usually do, but the direction
    # can be specified if need be.
    def adjacent?(source, target, direction=:all)
      if source.kind_of? Graphy::Arc
        raise NoArcError unless edge? source
        if target.kind_of? Graphy::Arc
          raise NoArcError unless edge? target
          (direction != :out and source.source == target.target) or (direction != :in and source.target == target.source)
        else
          raise NoVertexError unless vertex? target
          (direction != :out and source.source == target)  or (direction != :in and source.target == target)
        end
      else
        raise NoVertexError unless vertex? source
        if target.kind_of? Graphy::Arc
          raise NoArcError unless edge? target
          (direction != :out and source == target.target) or (direction != :in and source == target.source)
        else
          raise NoVertexError unless vertex? target
          (direction != :out and edge?(target,source)) or (direction != :in and edge?(source,target))
        end
      end
    end

    # Returns true if the graph has no vertex, i.e. num_vertices == 0.
    def empty?() vertices.size.zero?; end

    # Returns true if the given object is a vertex or Arc in the Graph.
    #
    def include?(x) x.kind_of?(Graphy::Arc) ? edge?(x) : vertex?(x); end

    # Returns the neighboorhood of the given vertex (or Arc)
    # This is equivalent to adjacent, but bases type on the type of object.
    # direction can be :all, :in, or :out
    def neighborhood(x, direction = :all)
      adjacent(x, :direction => direction, :type => ((x.kind_of? Graphy::Arc) ? :edges : :vertices ))
    end

    # Union of all neighborhoods of vertices (or edges) in the Enumerable x minus the contents of x
    # Definition taken from Jorgen Bang-Jensen, Gregory Gutin, _Digraphs: Theory, Algorithms and Applications_, pg 4
    def set_neighborhood(x, direction = :all)
      x.inject(Set.new) {|a,v| a.merge(neighborhood(v,direction))}.reject {|v2| x.include?(v2)}
    end

    # Union of all set_neighborhoods reachable in p edges
    # Definition taken from Jorgen Bang-Jensen, Gregory Gutin, _Digraphs: Theory, Algorithms and Applications_, pg 46
    def closed_pth_neighborhood(w,p,direction=:all)
      if p <= 0
        w
      elsif p == 1
        (w + set_neighborhood(w,direction)).uniq
      else
        n = set_neighborhood(w, direction)
        (w + n + closed_pth_neighborhood(n,p-1,direction)).uniq
      end
    end

    # Returns the neighboorhoods reachable in p steps from every vertex (or edge)
    # in the Enumerable x
    # Definition taken from Jorgen Bang-Jensen, Gregory Gutin, _Digraphs: Theory, Algorithms and Applications_, pg 46
    def open_pth_neighborhood(x, p, direction=:all)
      if    p <= 0
        x
      elsif p == 1
        set_neighborhood(x,direction)
      else
        set_neighborhood(open_pth_neighborhood(x, p-1, direction),direction) - closed_pth_neighborhood(x,p-1,direction)
      end
    end

    # Returns the number of out-edges (for directed graphs) or the number of
    # incident edges (for undirected graphs) of vertex _v_.
    def out_degree(v) adjacent(v, :direction => :out).size; end

    # Returns the number of in-edges (for directed graphs) or the number of
    # incident edges (for undirected graphs) of vertex _v_.
    def in_degree(v)  adjacent(v, :direction => :in ).size; end

    # Returns the sum of the number in and out edges for a vertex
    def degree(v) in_degree(v) + out_degree(v); end

    # Minimum in-degree
    def min_in_degree() to_a.map {|v| in_degree(v)}.min; end

    # Minimum out-degree
    def min_out_degree() to_a.map {|v| out_degree(v)}.min; end

    # Minimum degree of all vertexes
    def min_degree() [min_in_degree, min_out_degree].min; end

    # Maximum in-degree
    def max_in_degree() vertices.map {|v| in_degree(v)}.max; end

    # Maximum out-degree
    def max_out_degree() vertices.map {|v| out_degree(v)}.max; end

    # Minimum degree of all vertexes
    def max_degree() [max_in_degree, max_out_degree].max; end

    # Regular
    def regular?() min_degree == max_degree; end

    # Returns the number of vertices.
    def size()         vertices.size; end

    # Synonym for size.
    def num_vertices() vertices.size; end

    # Returns the number of edges.
    def num_edges()    edges.size; end

    # Utility method to show a string representation of the edges of the graph.
    def to_s() edges.to_s; end

    # Equality is defined to be same set of edges and directed?
    def eql?(g)
      return false unless g.kind_of? Graphy::Graph

      (g.directed?   == self.directed?)  and
      (vertices.sort == g.vertices.sort) and
      (g.edges.sort  == edges.sort)
    end

    # Synonym for eql?
    def ==(rhs) eql?(rhs); end

    # Merge another graph into this one
    def merge(other)
      other.vertices.each {|v| add_vertex!(v)      }
      other.edges.each    {|e| add_edge!(e)         }
      other.edges.each    {|e| add_edge!(e.reverse) } if directed? and !other.directed?
      self
    end

    # A synonym for merge, that doesn't modify the current graph
    def +(other)
      result = self.class.new(self)
      case other
      when Graphy::Graph then result.merge(other)
      when Graphy::Arc   then result.add_edge!(other)
      else result.add_vertex!(other)
      end
    end

    # Remove all vertices in the specified right hand side graph
    def -(other)
      case  other
      when Graphy::Graph then induced_subgraph(vertices - other.vertices)
      when Graphy::Arc   then self.class.new(self).remove_edge!(other)
      else self.class.new(self).remove_vertex!(other)
      end
    end

    # A synonym for add_edge!
    def <<(edge) add_edge!(edge); end

    # Return the complement of the current graph
    def complement
      vertices.inject(self.class.new) do |a,v|
        a.add_vertex!(v)
        vertices.each {|v2| a.add_edge!(v,v2) unless edge?(v,v2) }; a
      end
    end

    # Given an array of vertices return the induced subgraph
    def induced_subgraph(v)
      edges.inject(self.class.new) do |a,e|
        ( v.include?(e.source) and v.include?(e.target) ) ?  (a << e) : a
      end;
    end

    def inspect
      l = vertices.select {|v| self[v]}.map {|u| "vertex_label_set(#{u.inspect},#{self[u].inspect})"}.join('.')
      self.class.to_s + '[' + edges.map {|e| e.inspect}.join(', ') + ']' + (l && l != '' ? '.'+l : '')
    end

   private
    def edge_convert(*args) args[0].kind_of?(Graphy::Arc) ? args[0] : edge_class[*args]; end

  end # Graph

end # Graphy
