# Fracture
Unified view testing for your view or controller specs.

Fracture allows you to define text or selector once at the top of a spec file. It also allows grouping of multiple text or selectors snippets using one label.

Defining what you are looking for in one place prevents issues when a name (or selector) you are searching for is changed on a view which would only result in one failing spec, the other spec checking for the non exisitence would not fail so you would not find this 'always' passing spec.


### Example

To give you a simple example why would you use fracture gem, assume you have the following tests (without Fracture)

context "admin" 
```
 response.body.should have_text("Edit")
```
...
(Somewhere further down in your spec file)
...

context "user" 
```
 response.body.should_not have_text("Edit")
```
If the word 'Edit' was changed in your view to 'Modify' the first test would fail although the second test would not fail. In a small spec this may be obvious to see although in a large file it might not be found. This would leave you with a never failing spec and if the logic controlling the display of this text broke and allowed for it to display when you are a user this would never be detected.

####With Fracture:
You define the text "Edit" once at the top of your spec and now it can be used multiple times within the spec. If you change the text in the view, you only need to change the Fracture.define_text(:show_edit_button, "Modify") and all test using that definition will change.
```ruby
Fracture.define_text(:show_edit_button, "Edit")
```
context "admin"
```ruby
response.body.should have_fracture(:show_edit_button)
```
context "user"
```ruby
response.body.should_not have_fracture(:show_edit_button)
```

## Installation:
Gemfile
``` 
gem "fracture"
```

## Usage:
spec_helper.rb
```ruby
config.after :all do
  Fracture.clear
end
```

In your spec
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
Fracture.define_text(:edits, "Edit")
```
Multiple
```ruby
Fracture.define_text(:edits, "Edit", "Edit All")
```
### Selector
```ruby
Fracture.define_selector(:label_1, "#an_id", ".a_class", ".another_class")
```

Currently there is no way to build text and selectors into one definition (future feature). Another future feature will be to support within.

## Matchers
Example Definitions
```ruby
Fracture.define_text(:lable_1, "Fred")
Fracture.define_text(:label_2, "Barney", "Betty")
Fracture.define_text(:label_3, "Wilma")
```

Page should contain "Barney" and "Betty". Ignores any other definitions
```ruby
response.body.should have_fracture(:label_2)
```

Page should contain "Barney", "Betty", "Fred" and "Wilma"
```ruby
response.body.should have_fracture(:label_1, :label_2, :label_3)
```
or
```ruby
response.body.should have_all_fractures
```

Page should contain "Barney" and "Betty" and not "Fred" or "Wilma"
```ruby
response.body.should have_only_fractures(:label_2)
```

Page should contain "Barney", "Betty", "Fred" and not "Wilma"
```ruby
response.body.should have_all_fractures_except(:label_3)
```










