require 'cell/rails'
module PageCell
  class View

    class Conext
      def get_binding
        binding
      end
    end

    def self.parse_for_tag(dict, tag, args='')
      "#{tag} #{args.inspect}"
    end

    def self.render_cell(dict,args = '')
      return nil if args.blank?
      b = Conext.new.get_binding
      eval("name,opts = #{args}",b)
      name = eval("name",b)
      opts = eval("opts",b)

      name, state = name.to_s.strip.split("#")
      ::Cell::Rails.render_cell_for(name, state.to_sym, dict['controller'].value,opts)#, *args, &block)
    end
  end
end
