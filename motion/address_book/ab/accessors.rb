module AddressBook
  module AB
    module Accessors

      module AddressBook
        module_function

        def get_label(label_reference)
          ABAddressBookCopyLocalizedLabel(label_reference)
        end

        def new_connection
          options, error = [nil, nil]
          record_reference = ABAddressBookCreateWithOptions(options, error)
          raise(error) if error
          record_reference
        end

        def register_callback(record_reference, callback)
          ABAddressBookRegisterExternalChangeCallback(
            record_reference, callback, nil
          )
        end

        def save(connection)
          error = nil
          ABAddressBookSave(connection, error)
          raise(error) if error
        end

        def unsaved?(connection)
          ABAddressBookHasUnsavedChanges(connection)
        end
      end

      module Groups
        module_function

        def count(connection)
          ABAddressBookGetGroupCount(connection)
        end

        def find(connection, id)
          ABAddressBookGetGroupWithRecordID(connection, id)
        end

        def index(connection)
          ABAddressBookCopyArrayOfAllGroups(connection)
        end
      end

      module MultiValue
        module_function

        def append(record_reference, value, label)
          error = nil
          ABMultiValueAddValueAndLabel(record_reference, value, label, error)
          raise(error) if error
        end

        def count(record_reference)
          ABMultiValueGetCount(record_reference)
        end

        def find(record_reference)
          ABMultiValueCreateMutableCopy(record_reference)
        end

        def get_index(record_reference, index)
          ABMultiValueCopyValueAtIndex(record_reference, index)
        end

        def get_label_at_index(record_reference, index)
          ABMultiValueCopyLabelAtIndex(record_reference, index)
        end

        def get_value_at_index(record_reference, index)
          ABMultiValueCopyValueAtIndex(record_reference, index)
        end

        def property_type(record_reference)
          ABMultiValueGetPropertyType(record_reference)
        end

        def new_record(property_type)
          ABMultiValueCreateMutable(property_type)
        end
      end

      module People
        module_function

        def add_record(connection, record_reference)
          error = nil
          ABAddressBookAddRecord(connection, record_reference, error)
          raise(error) if error
        end

        def all_from_source(connection, source = nil)
          if source
            return ABAddressBookCopyArrayOfAllPeopleInSource(connection, source)
          end

          ABAddressBookCopyArrayOfAllPeople(connection)
        end

        def changed_since(connection, timestamp)
          index(connection)
            .select { |person| person.modification_date > timestamp }
        end

        def count(connection)
          ABAddressBookGetPersonCount(connection)
        end

        def find(connection, id)
          ABAddressBookGetPersonWithRecordID(connection, id)
        end

        def get_field(record_reference, field)
          ABRecordCopyValue(record_reference, field)
        end

        def get_uid(record_reference)
          ABRecordGetRecordID(record_reference)
        end

        # @param connection [ABAddressBook]
        # @param options [Hash]
        #   { ordering: <ABPersonSortOrdering>, source: <ABRecordRef> }
        def index(connection, options = {})
          ordering = options.fetch(:ordering) { ABPersonGetSortOrdering() }

          all_from_source(connection, options[:source])
            .sort { |a, b| ABPersonComparePeopleByName(a, b, ordering) }
        end

        def new_record
          ABPersonCreate()
        end

        def remove_field(record_reference, field)
          error = nil
          ABRecordRemoveValue(record_reference, field, error)
          raise(error) if error
        end

        def remove_record(connection, record_reference)
          error = nil
          ABAddressBookRemoveRecord(connection, record_reference, error)
          raise(error) if error
        end

        def set_field(field, value)
          error = nil
          ABRecordSetValue(record_reference, field, value, error)
          raise(error) if error
        end
      end

      module Sources
        module_function

        def index(connection)
          ABAddressBookCopyArrayOfAllSources(connection)
        end

        def type(record_reference)
          ABRecordCopyValue(record_reference, KABSourceTypeProperty)
        end
      end

    end
  end
end
