module AddressBook
  module AB
    class AddressBook
      include PublicInterface

      # @param autoconnect [Boolean] Whether or not we should automatically
      #   request access on creation
      def initialize(auto_connect = true)
        @native_ref = Accessors::AddressBook.new_connection
        connect if auto_connect
        self
      end

      def connect(&after_connect)
        if connected?
          return (after_connect.nil? ? @native_ref : after_connect.call)
        end

        request_authorization do |success, error|
          raise "Unable to create a connection" unless connected?
          after_connect.call if success && after_connect
        end
      end

      # If set, @native_ref will be a __NSCFType, which, unfortunately, is not
      # something you can easily query for, so we check the pointer description
      def connected?
        Utilities.address_book?(@native_ref) && Authorization.granted?
      end

      # @param block [Proc] will receive one boolean argument indicating whether
      #   or not access to the address book was granted. If no block is given,
      #   this request will be blocking
      def request_authorization(&block)
        synchronous = !block

        Authorization.request(@native_ref) do |granted, error|
          raise(error) if !granted && error
          @access_granted = granted
          block.call(@access_granted) unless block.nil?
        end

        # Wait on the asynchronous callback before returning.
        while(synchronous && @access_granted.nil?) do sleep 0.1 end

        @access_granted
      end

      # Will ensure that changes to the address book are emitted via the
      # standard notification center for observation, e.g.
      #
      # notify_on_changes!
      #
      # my_callback = Proc.new do |notification|
      #   NSLog "Address Book was changed!"
      # end
      #
      # NSNotificationCenter.defaultCenter.addObserverForName(
      #   :addressbook_updated,
      #   object: nil,
      #   queue: NSOperationQueue.mainQueue,
      #   usingBlock: my_callback
      # )
      #
      # Or if you're using BubbleWrap:
      #
      # App.notification_center.observe(:addressbook_updated, &my_callback)
      def notify_on_changes!
        ensure_connection! { register_callback(notifier) }
      end

      def register_callback(callback)
        Accessors::AddressBook.register_callback(@native_ref, callback)
      end

      # @param callback [Proc] will receive 3 arguments on changes to the
      #   address book, the @native_ref that was changed, a nil value, and the
      #   context
      def track_changes(&callback)
        ensure_connection! { register_callback(callback) }
      end

      private

      def connected_groups
        Accessors::Groups.index(@native_ref)
          .map { |group| connected_groups_new(group) }
      end

      def connected_groups_count
        Accessors::Groups.count(@native_ref)
      end

      def connected_groups_new(attributes)
        Group.new(attributes, @native_ref)
      end

      def connected_groups_create(attributes)
        connected_groups_new(attributes).save
      end

      def connected_groups_find(id)
        ab_group = Accessors::Groups.find(@native_ref, id)
        ab_group && connected_groups_new(ab_group)
      end

      def connected_contacts(options = {})
        Accessors::People.index(@native_ref, options)
          .map { |ab_person| connected_contact_new(ab_person) }
      end

      def connected_contacts_changed_since(timestamp)
        Accessors::People.changed_since(@native_ref, timestamp)
      end

      def connected_contacts_count
        Accessors::People.count(@native_ref)
      end

      def connected_contacts_where(conditions)
        connected_contacts.select { |person| person.matches? conditions }
      end

      def connected_contact_new(attributes)
        Person.new(attributes, @native_ref)
      end

      def connected_contact_create(attributes)
        connected_contact_new(attributes).save
      end

      def connected_contact_find(id)
        ab_person = Accessors::People.find(@native_ref, id)
        ab_person && connected_contact_new(ab_person)
      end

      def connected_sources
        Accessors::Sources.index(@native_ref).map { |s| Source.new(s) }
      end

      def notifier
        @notifier ||= Proc.new do |_ab_instance, _always_nil, _context|
          NSNotificationCenter.defaultCenter.postNotificationName(
            :addressbook_updated,
            object: self,
            userInfo: nil
          )
        end
      end
    end
  end
end
