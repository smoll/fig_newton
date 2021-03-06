require 'fig_newton/overrides'
require 'yaml'
require 'socket'

module FigNewton
  module Missing
    include FigNewton::Overrides

    def method_missing(*args, &block)
      read_file unless @yml
      m = args.first
      value = @yml[m.to_s]
      value = args[1] unless value || type_bool?(value)
      value = block.call(m.to_s) unless value || block.nil? || type_bool?(value)
      super unless value || type_bool?(value)
      value = FigNewton::Node.new(value) unless type_known? value
      env = check_for_override(m, value)
      env.nil? ? value : env
    end

    def read_file
      @yml = nil
      @yml = YAML.load_file "#{yml_directory}/#{ENV['FIG_NEWTON_FILE']}" if ENV['FIG_NEWTON_FILE']
      unless @yml
        hostname = Socket.gethostname
        hostfile = "#{yml_directory}/#{hostname}.yml"
        @yml = YAML.load_file hostfile if File.exist? hostfile
      end
      FigNewton.load('default.yml') if @yml.nil?
    end

    private

    def type_known?(value)
      value.is_a?(String) || value.is_a?(Integer) || type_bool?(value)
    end

    def type_bool?(value)
      value.is_a?(TrueClass) || value.is_a?(FalseClass)
    end
  end
end
