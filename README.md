# Fracture
Unified view testing for your view or controller specs.

Fracture allows you to define text or selector once at the top of a spec file. It also allows grouping of multiple text snippets or selectors using one label.

Defining what you are looking for in one place prevents issues when a name (or selector) you are searching for is changed on a view which would only result in one failing spec, the other spec checking for the non exisitence would not fail so you would not find this 'always' passing spec.


### Example

To give you a simple example why would you use fracture gem, assume you have the test (psuedo code):

<pre>
As an Admin the 'Edit' button should appear
As a User the 'Edit' button should not appear
</pre>

If 'Edit' was changed to 'Modify' the first test would fail although the second test would not fail. In a small spec this would be obvious to see although in a large file it might not be seen.

With Fracture:
Fracture.define_text(:change_it, "Edit")

<pre>
as admin: response.body.should have_fracture(:change_it)
as user: response.body.should_not have_fracture(:change_it)
</pre>

## Installation:

``` 
gem install fracture
```

## Usage:

spec_helper.rb
  config.after :all do
    Fracture.clear
  end
or as a 1 linere
  config.after(:all) { Fracture.clear }


in your spec
for controllers you will need to add *render_views*

```ruby
require 'spec_helper'

describe ContactsController do
  render_views

  Fracture.define_text(:add, "New")

  context "as admin" do
    describe "as an admin" do
      it "index" do
        login_as :admin # psuedo code for example
        get :index
        response.body.should have_fracture(:add)
      end
    end
  end

  context "as user" do
    describe "as an user" do
      it "index" do
        login_as :user # psuedo code for example
        get :index
        response.body.should have_fracture(:add)
      end
    end
  end
end
```

## Definitions
### Text
Single
```ruby
Fracture.define_text(:edits, "edit", "edit all")
```
Multiple
```ruby
Fracture.define_text(:edits, "edit", "edit all")
```
### Selector
```ruby
Fracture.define_selector(:label_1, "#an_id", ".a_class", ".another_class")
```

Currently ther is no way to build text and selectors into one definition (future feature). Another future feature will be to support within.

## Matchers
```ruby
Fracture.define_text(:lable_1, "Fred")
Fracture.define_text(:label_2, "Barney", "Betty")
Fracture.define_text(:label_3, "Wilma")
```

Page should contain "Barney" and "Betty". Ignores any other definitions
```ruby
response.body.shoud have_fracture(:label_2)
```

Page should contain "Barney", "Betty", "Fred" and "Wilma"
```ruby
response.body.shoud have_fracture(:label_1, :label_2, :label_3)
```
or
```ruby
response.body.shoud have_all_fractures
```

Page should contain "Barney" and "Betty" and not "Fred" or "Wilma"
```ruby
response.body.shoud have_only_fractures(:label_2)
```

Page should contain "Barney", "Betty", "Fred" and not "Wilma"
```ruby
response.body.shoud have_all_fractures_except(:label_3)
```










