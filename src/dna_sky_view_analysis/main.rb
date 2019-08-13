require 'sketchup.rb'
require_relative 'dome'
require_relative 'utils'


module ArchTools
  module SkyViewAnalysis
    
    class DomeTool

      def activate
        @center = Sketchup::InputPoint.new
        @radius = nil
        @accuracy = nil
        update_ui
      end


      def deactivate(view)
        view.invalidate
      end


      def resume(view)
        update_ui
        view.invalidate
      end


      def onCancel(reason, view)
        reset_tool
        view.invalidate
      end


      def onMouseMove(flags, x, y, view)
        update_ui
        view.invalidate
      end


      def onLButtonDown(flags, x, y, view)
        @center.pick(view, x, y) unless center_is_valid?
        update_ui
        view.invalidate
      end


      CURSOR_POINT = UI.create_cursor(File.join(PLUGIN_DIR, "res/tool_icon.png"), 0, 0)
      def onSetCursor
        UI.set_cursor(CURSOR_POINT)
      end


      def draw(view)
        draw_preview(view)
      end


      def onUserText(text, view)
        begin
          values = text.split("@")
          @radius = values[0].to_l
          @accuracy = values[1].to_i <= 0 ? 50 : values[1].to_i
          @accuracy -= 1 if @accuracy.odd? # accuracy check
          draw_dome
        rescue ArgumentError
          UI.messagebox("Invalid numbers. Please insert numeric values like this 45@100 or 45@ (default accuracy is 50)")
        end
      end


      private

      def draw_dome
        model = Sketchup.active_model
        current_layer = "sky_exposure"

        model.start_operation("Create Dome", true)

        ArchTools::SkyViewAnalysis.create_layers
        model.active_layer = current_layer

        ArchTools::SkyViewAnalysis.hide_all_except([current_layer], true)

        dome = Dome.new(@center.position, @radius, @accuracy)
        dome.create_dome_geometry

        ArchTools::SkyViewAnalysis.show_layers
        model.select_tool(nil)
        model.active_layer = "Layer0"

        model.commit_operation
      end

      def update_ui
        unless center_is_valid?
          Sketchup.status_text = "Select center point."
        else
          if @radius.nil? || @accuracy.nil?
            Sketchup.status_text = "Type radius and accuracy - even number - separated by @. E.g. 55@100"
          else
            Sketchup.status_text = "Done"
          end
        end
      end


      def reset_tool
        @center.clear
        @radius = nil
        @accuracy = nil
        update_ui
      end


      def center_is_valid?
        @center.valid?
      end


      def draw_preview(view)
        color = "red"
        style = 1
        size = 10
        view.draw_points(@center.position, size, style, color)
      end

    end # end Dome


    def self.activate_dome_tool
      Sketchup.active_model.select_tool(DomeTool.new)
    end


    def self.sef_calculation
      model = Sketchup.active_model
      model.start_operation("Calculate SEF", true)
      begin
        rays, dome_guid, area = self.get_rays
        self.calculate_intersection(rays, dome_guid, area)
      rescue
        UI.messagebox("Please, select a dome geometry.")
      end
      model.commit_operation
    end

    
    def self.svf_calculation
      model = Sketchup.active_model
      model.start_operation("Calculate SVF", true)
      begin
        model.active_layer = "sky_view_factor"
        
        self.hide_all_except(["sky_view_factor", "sky_exposure"], true)
        self.sky_view_factor_mask
        self.show_layers
        model.active_layer = "Layer0"
      rescue
        UI.messagebox("Please, select a SEF dome geometry.")
        model.active_layer = "Layer0"
        self.show_layers
      end
      model.commit_operation
    end

    unless file_loaded?(__FILE__)
      toolbar = UI::Toolbar.new "Sky View Analysis"

      cmd = UI::Command.new("Create Dome") { self.activate_dome_tool }
      cmd.small_icon = "res/dome_icon.png"
      cmd.large_icon = "res/dome_icon.png"
      cmd.tooltip = "Create Dome"
      cmd.status_bar_text = "Use this command to create Dome.\nSuggested accuracy range - from 50 to 150."

      toolbar = toolbar.add_item(cmd)

      cmd = UI::Command.new("Create Sky Exposure Mask") { self.sef_calculation }
      cmd.small_icon = "res/sef_icon.png"
      cmd.large_icon = "res/sef_icon.png"
      cmd.tooltip = "Create Sky Exposure Mask"
      cmd.status_bar_text = "Use this command to create Sky Exposure Mask.\nSelect dome geometry before executing this command."

      toolbar = toolbar.add_item(cmd)

      cmd = UI::Command.new("Create Sky View Factor Mask") { self.svf_calculation }
      cmd.small_icon = "res/svf_icon.png"
      cmd.large_icon = "res/svf_icon.png"
      cmd.tooltip = "Create Sky View Factor Mask"
      cmd.status_bar_text = "Use this command to create Sky View Factor Mask.\nSelect a Sky Exposure Mask before executing this command."
      toolbar = toolbar.add_item(cmd)

      toolbar.show

      file_loaded(__FILE__)
    end

  end # end SkyViewAnalysis
end # end ArchTools