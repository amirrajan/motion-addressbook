module AddressBook
  module Shared
    module Hashable
      def attributes
        response = {}
        instance_variables.each do |var|
          response[variable_as_sym(var)] = instance_variable_get(var)
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
