# Customization of the RGL dot module since it isn't very customizable
# by default

require 'rgl/rdot'

module RGL
  module Graph

    # Returns a label for vertex v. Default is v.to_s
    def vertex_label(v)
      v.to_s
    end

    def vertex_id(v)
      v
    end

    # Return a RGL::DOT::Digraph for directed graphs or a DOT::Graph for an
    # undirected Graph. _params_ can contain any graph property specified in
    # rdot.rb.
    #
    def to_dot_graph(params = {})
      params['name'] ||= self.class.name.gsub(/:/, '_')
      fontsize       = params['fontsize'] ? params['fontsize'] : '8'
      graph          = (directed? ? DOT::Digraph : DOT::Graph).new(params)
      edge_class     = directed? ? DOT::DirectedEdge : DOT::Edge

      each_vertex do |v|
        node = DOT::Node.new(
            'name'     => vertex_id(v),
            'fontsize' => fontsize,
            'label'    => vertex_label(v),
					  'shape' => 'box'
        )

        v.instance_methods.each do |m|
          node << DOT::Node.new(
              'name'     => m.name,
              'fontsize' => fontsize,
              'label'    => m.to_s,
              'shape' => 'plain'
          )
        end

        v.class_methods.each do |m|
        end

        graph << node

      end

      each_edge do |u, v|
        graph << edge_class.new(
            'from'     => vertex_id(u),
            'to'       => vertex_id(v),
            'fontsize' => fontsize
        )
      end

      graph
    end

    # Output the DOT-graph to stream _s_.
    def print_dotted_on(params = {}, s = $stdout)
      s << to_dot_graph(params).to_s << "\n"
    end

    # Call dotty[http://www.graphviz.org] for the graph which is written to the
    # file 'graph.dot' in the current directory.
    #
    def dotty(params = {})
      dotfile = "graph.dot"
      File.open(dotfile, "w") do |f|
        print_dotted_on(params, f)
      end
      #unless system("dotty", dotfile)
        #raise "Error executing dotty. Did you install GraphViz?"
      #end
    end

    # Use dot[http://www.graphviz.org] to create a graphical representation of
    # the graph. Returns the filename of the graphics file.
    def write_to_graphic_file(fmt='png', dotfile="graph")
      src = dotfile + ".dot"
      dot = dotfile + "." + fmt

      File.open(src, 'w') do |f|
        f << self.to_dot_graph.to_s << "\n"
      end

      unless system("dot -T#{fmt} #{src} -o #{dot}")
        raise "Error executing dot. Did you install GraphViz?"
      end
      dot
    end

  end
end
