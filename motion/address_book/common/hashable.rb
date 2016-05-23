module AddressBook
  module Common
    module Hashable
      def to_h
        response = {}
        instance_variables.each do |var|
          var_val = instance_variable_get(var)

          response[variable_as_sym(var)] =
            if var_val.is_a?(Array)
              var_val.map { |array_value| to_h_if_possible(array_value) }
            elsif var_val.is_a?(NSDateComponents)
              standard_calendar.dateFromComponents(var_val)
            else
              to_h_if_possible(var_val)
            end
        end
        response
      end
      alias :to_hash :to_h

      def variable_as_sym(variable)
        variable.to_s.gsub(/^@/, '').to_sym
      end

      private

      def standard_calendar
        NSCalendar.alloc.initWithCalendarIdentifier(NSCalendarIdentifierGregorian)
      end

      def to_h_if_possible(value)
        value.respond_to?(:to_h) ? value.to_h : value
      end
    end
  end
end
