module AddressBook
  module AB
    module UI
      class Picker
        class << self
          attr_accessor :showing

          def show(options={}, &after)
            raise "Cannot show two Pickers" if showing?
            @picker = new(options[:ab] || AddressBook::AddrBook.instance, &after)
            @picker.show options
            @picker
          end

          def showing?
            !!showing
          end
        end

        def initialize(ab, &after)
          @ab = ab
          @after = after
        end

        def show(options)
          self.class.showing = true

          @people_picker_ctlr = ABPeoplePickerNavigationController.alloc.init
          @people_picker_ctlr.peoplePickerDelegate = self

          @presenter = options.fetch :presenter, UIApplication.sharedApplication.keyWindow.rootViewController
          @animated = options.fetch :animated, true
          @presenter.presentViewController(@people_picker_ctlr, animated: @animated, completion: nil)
        end

        def hide(ab_person=nil)
          person = ab_person && @ab.person(ABRecordGetRecordID(ab_person))
          completion_handler = lambda do
            @after.call(person) if @after
            self.class.showing = false
          end

          @presenter.dismissViewControllerAnimated(@animated, completion: completion_handler)
        end

        # iOS 8+
        def peoplePickerNavigationController(people_picker, didSelectPerson: ab_person)
          hide(ab_person)
        end

        def peoplePickerNavigationController(people_picker, didSelectPerson: ab_person, property:_, identifier:_)
          hide(ab_person)
        end

        # iOS 7 and below - deprecated in iOS 8+
        def peoplePickerNavigationController(people_picker, shouldContinueAfterSelectingPerson:ab_person)
          hide(ab_person)
          false
        end

        def peoplePickerNavigationController(people_picker, shouldContinueAfterSelectingPerson:ab_person, property:_, identifier:_)
          hide(ab_person)
          false
        end

        # iOS 2+
        def peoplePickerNavigationControllerDidCancel(people_picker)
          hide
        end
      end
    end
  end
end
