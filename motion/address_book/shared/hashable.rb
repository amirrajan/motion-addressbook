module AddressBook
  module Shared
    module Hashable
      def attributes
        response = {}
        instance_variables.each do |var|
          var_val = instance_variable_get(var)

          response[variable_as_sym(var)] =
            var_val.respond_to?(:to_h) ? var_val.to_h : var_val
        end
        response
      end
      alias :to_h :attributes
      alias :to_hash :to_h

      def variable_as_sym(variable)
        variable.to_s.gsub(/^@/, '').to_sym
      end
    end
  end
end
