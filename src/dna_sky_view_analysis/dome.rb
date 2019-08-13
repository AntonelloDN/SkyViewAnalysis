require 'sketchup.rb'


module ArchTools
  module SkyViewAnalysis

    class Dome

      QUARTER = 4

      attr_accessor :center, :radius, :accuracy

      def initialize(center, radius, accuracy)
        @center = center
        @radius = radius
        @accuracy = accuracy
      end


      def create_dome_geometry
        model = Sketchup.active_model
        entities = model.active_entities

        center_point = self.center

        arc_vector_end = Geom::Vector3d.new(0,1,0).normalize!
        arc_vector_start = Geom::Vector3d.new(-1,0,0)
        circle_vector = Geom::Vector3d.new(0,0,1)

        edges = entities.add_arc(center_point, arc_vector_start, arc_vector_end, self.radius, 0.degrees, 90.degrees, (self.accuracy / QUARTER).round)
        edges = edges.first.curve
        face = entities.add_face(edges.vertices << center_point)

        # create circle
        circle = entities.add_circle(center_point, circle_vector, self.radius, self.accuracy)
        c_point = entities.add_cpoint(center_point)

        group = entities.add_group(face, circle, c_point)
        group.make_unique

        # add attribute to group
        group.set_attribute("geometry", "center", center_point)
        group.set_attribute("geometry", "radius", self.radius)

        result = face.followme(circle)
        # to do - if necessary, check result and do something
      end

    end # class Dome

  end # end SkyViewAnalysis
end # end ArchTools