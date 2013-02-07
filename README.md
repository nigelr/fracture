# Fracture
Unified view testing for your view or controller specs.

Fracture allows you to define text or selector once at the top of a spec file. It also allows grouping of multiple text or selectors snippets using one label.

Defining what you are looking for in one place prevents issues when a name (or selector) you are searching for is changed on a view which would only result in one failing spec, the other spec checking for the non exisitence would not fail so you would not find this 'always' passing spec.


### Example

A simple example why would you use the fracture gem, assume you have the following tests (without Fracture)

context "admin" 
```ruby
 response.body.should have_text("Edit")
```
...

(Somewhere further down in your spec file)

...

context "user" 
```ruby
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
This is to clear the set Fractures between each spec file


#### In your spec
If you want to test views from the controller spec you will need to add *render_views*, fracture will also work within view specs.

```ruby
require 'spec_helper'

describe ContactsController do
  render_views

  before(:all) do 
    Fracture.define_text(:add, "New")
  end
    
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

Currently there is no way to build text and selectors into one definition (future feature). Another future feature will be to support 'within'.

## Matchers
Example Definitions
```ruby
Fracture.define_text(:label_1, "Fred")
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

### Forms
Check to see if there is a form
```ruby
response.body.should have_a_form
```
Check to see if its a new form or editing (checks method is POST or PUT)
```ruby
response.body.should have_a_form.that_is_new
response.body.should have_a_form.that_is_edit
```
Check to path form posts to
```ruby
response.body.should have_a_form.that_is_new.with_path_of("/tickets")
response.body.should have_a_form.with_path_of(tickets_path)
```

### Integration Specs Example
```ruby
page.body.should have_only_fractures(:label_2)
```




## All Methods:

* have_fracture(*labels)
* have_all_fractures
* have_all_fractures_except(*labels)
* have_only_fractures(*labels)
* have_a_form
 - that_is_new
 - that_is_edit
 - with_path_of(path)

# TODO

* Support text and selector in one fracture
* Support qty of expected fractures on page (selector count)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request







