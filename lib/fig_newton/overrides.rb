require 'coercible'

module FigNewton
  module Overrides
    def check_for_override(name, expected_value)
      env_return = ENV[name.to_s.upcase]
      return nil if env_return.nil?
      return nil unless override_permissible? && env_var_valid?(env_return, expected_value)
      coerce(env_return, expected_value)
    end

    private

    def override_permissible?
      flag = ENV['FIG_ENV_OVERRIDES']
      return false unless flag && coercible?(flag, true)
      coerce(flag, true)
    end

    def env_var_valid?(env_return, ref_obj)
      return false if env_return.nil? || !coercible?(env_return, ref_obj)
      true
    end

    # Private: Check if env_return is coercible into another ref_obj type
    #
    # Examples
    #
    # coercible?('1234', 1)
    # # => true
    #
    # coercible('durr', false)
    # # => false
    #
    # coercible('false', false)
    # # => true
    def coercible?(env_return, ref_obj)
      converter = converter_method(ref_obj)
      return true if converter == :to_s
      Coercible::Coercer.new[String].send(converter, env_return)
      return true
    rescue Coercible::UnsupportedCoercion
      false
    end

    def coerce(env_return, ref_obj)
      converter = converter_method(ref_obj)
      return env_return if converter == :to_s
      Coercible::Coercer.new[String].send(converter, env_return)
    end

    def converter_method(ref_obj)
      case ref_obj
      when TrueClass || FalseClass
        :to_boolean
      when String
        :to_s
      when Integer
        :to_i
      end
    end
  end
end
