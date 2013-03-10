RSpec::Matchers.define :have_fracture do |*fracture_labels|
  match do |page|
    @results = Fracture.test_fractures page, false, fracture_labels, nil
    @results[:passed]
  end

  match_for_should_not do |page|
    @results = Fracture.test_fractures page, true, fracture_labels, nil
    @results[:passed]
  end

  failure_message_for_should { |actual| common_error(actual, @results) }
  failure_message_for_should_not { |actual| common_error(actual, @results) }
end

RSpec::Matchers.define :have_all_fractures do
  match do |page|
    @results = Fracture.test_fractures page, false, Fracture.all.keys, nil
    @results[:passed]
  end

  match_for_should_not do |page|
    @results = Fracture.test_fractures page, true, Fracture.all.keys, nil
    @results[:passed]
  end

  failure_message_for_should { |actual| common_error(actual, @results) }
  failure_message_for_should_not { |actual| common_error(actual, @results) }
end

RSpec::Matchers.define :have_all_fractures_except do |*fracture_labels|
  match do |page|
    @results = Fracture.have_all_except_test(page, false, fracture_labels)
    @results[:passed]
  end

  match_for_should_not do |page|
    @results = Fracture.have_all_except_test(page, true, fracture_labels)
    @results[:passed]
  end

  failure_message_for_should { |actual| common_error(actual, @results) }
  failure_message_for_should_not { |actual| common_error(actual, @results) }
end

RSpec::Matchers.define :have_only_fractures do |*fracture_labels|
  match do |page|
    @results = Fracture.have_only_test(page, false, fracture_labels)
    @results[:passed]
  end

  match_for_should_not do |page|
    @results = Fracture.have_only_test(page, true, fracture_labels)
    @results[:passed]
  end

  failure_message_for_should { |actual| common_error(actual, @results) }
  failure_message_for_should_not { |actual| common_error(actual, @results) }
end

def common_error(actual, results)
  errors = ""
  unless results[:should].empty?
    errors += "expected to find '#{results[:should].map { |i| i[:label] }.join(", ")}'"
  end
  unless results[:should_not].empty?
    errors += "expected not to find '#{results[:should_not].map { |i| i[:label] }.join(", ")}'"
  end
  errors += "\non page of\n #{Fracture.get_body(actual)}"
end

RSpec::Matchers.define :have_a_form do
  match do |page|
    page = Nokogiri::HTML.parse(page)
    @edit_found = page.at("input[type='hidden'][name='_method'][value='put']")
    @has_form = page.at("form[method='post']")
    #TODO refactor this
    #@found_action = page.at("form[action]").try(:attributes).try(:fetch, "action", nil).try(:value)
    @found_action = page.at("form[action]") &&
        page.at("form[action]").attributes &&
        page.at("form[action]").attributes.fetch("action", nil) &&
        page.at("form[action]").attributes.fetch("action", nil).value
    @has_form && !(@new_form && @edit_found) && (!@edit_form || @edit_found) && (!@expected_path || (@found_action == @expected_path))
  end

  match_for_should_not do |page|
    raise "Cannot use should_not chained with .is_for, .that_is_edit or .with_path_of " if @new_form || @edit_form || @expected_path
    page = Nokogiri::HTML.parse(page)
    !page.at("form[method='post']")
  end

  #chain(:for_action) { |action #new:edit| @new_form = true }
  chain(:that_is_new) { @new_form = true }
  chain(:that_is_edit) { @edit_form = true }
  #chain(:with_path) { |path| @expected_path = path }
  chain(:with_path_of) { |path| @expected_path = path }
  failure_message_for_should do
    ret = case
      when !@has_form
        "expected to find a form on the page\n"
      when @new_form && @edit_found
        'Form is an edit'
      when @edit_form && !@edit_found
        'Form is not an edit'
      when @expected_path
        "Expected to find forms action of '/#{@expected_path}' but found '/#@found_action'"
      else
        raise "Unexpected have_form state."
    end
    ret
  end
  failure_message_for_should_not { "expected not to find a form on the page" }
end
