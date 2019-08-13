require 'sketchup.rb'


module ArchTools
  module SkyViewAnalysis

    def self.create_layers
      model = Sketchup.active_model
      layers = model.layers
      materials = model.materials

      svf = layers.add("sky_view_factor")
      svf.color = Sketchup::Color.new("#6897bb")

      sef = layers.add("sky_exposure")
      sef.color = Sketchup::Color.new("#00dbff")

      material_sky = materials.add("Dome Sky Visible")
      material_sky.alpha = 0.5
      material_sky.color = "#26D4DF"

      material_dome = materials.add("Dome Sky Shading")
      material_dome.color = "#000000"
    end


    def self.hide_all_except(layer, condition)
      hide_except = condition ? lambda { |l| l.visible = false unless layer.include?(l.name) } : lambda { |l| l.visible = false if layer.include?(l.name) }
      model = Sketchup.active_model
      model.layers.each { |l| hide_except.call(l) }
    end
  
  
    def self.show_layers
      show_layer = lambda { |l| l.visible = true }
      model = Sketchup.active_model
      model.layers.each { |l| show_layer.call(l) }
    end
    

    def self.direction_from_two_points(pt1, pt2)
      dx = pt2.x - pt1.x
      dy = pt2.y - pt1.y
      dz = pt2.z - pt1.z

      Geom::Vector3d.new(dx, dy, dz)
    end


    def self.get_rays
      model = Sketchup.active_model
      selection = model.selection

      group_dome = selection.grep(Sketchup::Group).first

      dome_guid = group_dome.guid
      base_face = group_dome.entities.grep(Sketchup::Face).to_a.last

      group_dome.entities.to_a.grep(Sketchup::Face).each { |face| face.reverse! } if base_face.normal.z == 1 # fix wrong dir of faces

      rays = []
      center_point = group_dome.get_attribute("geometry", "center")
      radius = group_dome.get_attribute("geometry", "radius")

      area = 0
      group_dome.entities.each do |element|
        if element.is_a?(Sketchup::Face)
          if element.area != base_face.area
            pt = element.bounds.center
            rays << [center_point, self.direction_from_two_points(center_point, [pt.x - radius + center_point.x, pt.y - radius + center_point.y, pt.z])]
            area += element.area
          end
        end
      end

      selection.clear

      return rays, dome_guid, area
    end


    def self.calculate_intersection(rays, dome_guid, area)
      model = Sketchup.active_model
      entities = model.active_entities
      
      self.hide_all_except(["sky_exposure"], false)

      pattern = []
      rays.each do |ray|
        items = model.raytest(ray, true)
        if items.nil?
          pattern << false
        else
          pattern << true
        end
      end
      self.show_layers

      current_dome_group = entities.grep(Sketchup::Group).find{|e| e.guid == dome_guid}
      
      free_area = 0

      current_dome_group.entities.to_a.grep(Sketchup::Face).each_with_index do |face, index|
        if index != pattern.size
          if pattern[index]
            face.material = face.back_material = "Dome Sky Shading"
          else
            face.material = face.back_material = "Dome Sky Visible"
            free_area += face.area
          end
        end
      end

      # sky exposure factor
      sef = ((free_area / area) * 100).round(1)

      UI.messagebox("Sky Exposure = " + sef.to_s)
    end


    def self.sky_view_factor_mask
      model = Sketchup.active_model
      selection = model.selection
      entities = model.active_entities

      group_dome = selection.grep(Sketchup::Group).first
      base_face = group_dome.entities.grep(Sketchup::Face).to_a.last

      center_point = group_dome.get_attribute("geometry", "center")
      radius = group_dome.get_attribute("geometry", "radius")

      visible_area = 0
      group_svf = entities.add_group

      group_dome.entities.each do |element|
        if element.is_a?(Sketchup::Face)
          if element != base_face
            pts = []
            element.vertices.each { |vertex| pts << [vertex.position.x - radius + center_point.x, vertex.position.y - radius + center_point.y, 0] }
            shading = group_svf.entities.add_face(pts)
            if element.material.name == "Dome Sky Shading"
              shading.material = shading.back_material = "Dome Sky Shading"
            else
              shading.material = shading.back_material = "Dome Sky Visible"
              visible_area += shading.area
            end
          end

        end
      end

      # sky view factor
      svf = ((visible_area / base_face.area) * 100).round(1)

      group_svf.entities.add_text(svf.to_s, center_point, Z_AXIS)

      UI.messagebox("Sky View Factor = " + svf.to_s)

    end

  end # end SkyViewAnalysis
end # end ArchTools