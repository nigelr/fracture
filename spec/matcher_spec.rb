require 'rspec'
require 'nokogiri'
require "fracture/fracture"
require "fracture/matchers/matcher"

describe Fracture do
  context 'path' do
    let (:body) {
      <<BODY
<body>
    <a href="/companies">Index</a>
    <a href="/companies/12">Show</a>
    <a href="/companies/12/edit">Edit</a>
    <a href="/companies/new">New</a>
    <a href="/companies/12" data-method="delete">Delete</a>

    <a href="/companies/12/contacts">Index</a>
    <a href="/companies/12/contacts/345">Show</a>
    <a href="/companies/12/contacts/345/edit">Edit</a>
    <a href="/companies/12/contacts/new">New</a>
    <a href="/companies/12/contacts/345" data-method="delete">Delete</a>
</body>

BODY
    }
=begin
  # Examples
  companies_link
  company_link
  edit_company_link
  new_company_link
  delete_company_link
=end
    let(:page_parsed) { Nokogiri::HTML.parse(body) }

    it 'concept 3' do
      build = []
      page_parsed.css('a[href]').map do |item|
        build << item['href']+(item['data-method'] ? '/delete' :'')
      end
      # index
      p build.grep /\/companies\/\d+\/contacts$/
      # show
      p build.grep /\/companies\/\d+\/contacts\/\d+$/
      # edit
      p build.grep /\/companies\/\d+\/contacts\/\d+\/edit$/
      # new
      p build.grep /\/companies\/\d+\/contacts\/new$/
      # delete
      p build.grep /\/companies\/\d+\/contacts\/\d+\/delete$/
    end
  end

  context "form" do
    context "when no form exists" do
      before { @page = "<p>not a form</p>" }
      it("should not have a form") { @page.should_not have_a_form }
      it("should have a form") { expect { @page.should have_a_form }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected to find a form on the page/) }
    end
    context "when form exists" do
      before { @page = "<form method='post' action='/companies'>" }
      it("should have a form") { @page.should have_a_form }
      it("should not have a form") { expect { @page.should_not have_a_form }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected not to find a form on the page/) }
      context "that_is_new" do
        it("should be a new form") { @page.should have_a_form.that_is_new }
        it("should not be an edit") { expect { @page.should have_a_form.that_is_edit }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Form is not an edit/) }
      end
      context "that_is_edit" do
        context "method is put" do
          before { @page += "<input type='hidden' name='_method' value='put'>" }
          it "should not be a new form" do
            expect { @page.should have_a_form.that_is_new }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Form is an edit/)
          end
          it("should be an edit form") { @page.should have_a_form.that_is_edit }
          it("should have a form") { @page.should have_a_form }
        end
        context "method is patch" do
          before { @page += %q[<input name="_method" type="hidden" value="patch" />] }
          it "should not be a new form" do
            expect { @page.should have_a_form.that_is_new }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Form is an edit/)
          end
          it("should be an edit form") { @page.should have_a_form.that_is_edit }
          it("should have a form") { @page.should have_a_form }
        end
      end
      context "with_path_of" do
        it "should match path" do
          @page.should have_a_form.with_path_of("/companies")
        end
        it "should not match path" do
          expect { @page.should have_a_form.with_path_of("/fred") }.to raise_error(RSpec::Expectations::ExpectationNotMetError, "Expected to find forms action of '//fred' but found '//companies'")
        end
      end
    end
    context "not support should_not when chained" do
      it "should raise error if that_is_edit" do
        expect { @page.should_not have_a_form.that_is_edit }.to raise_error(RuntimeError, "Cannot use should_not chained with .is_for, .that_is_edit or .with_path_of ")
      end
      it "should raise error if that_is_new" do
        expect { @page.should_not have_a_form.that_is_new }.to raise_error(RuntimeError, "Cannot use should_not chained with .is_for, .that_is_edit or .with_path_of ")
      end
      it "should raise error if with_path_of" do
        expect { @page.should_not have_a_form.with_path_of("/abc") }.to raise_error(RuntimeError, "Cannot use should_not chained with .is_for, .that_is_edit or .with_path_of ")
      end
    end
  end

  context "Fracture" do
    it "non existent fracture label" do
      expect { @page.should have_fracture(:dont_exist) }.to raise_error(RuntimeError, "Fracture with Label of 'dont_exist' was not found")
    end

    before do
      Fracture.clear
      @page = <<sample
                  <h1>Opening</h1>
                  <table>
                    <tr>
                      <th>abc</th>
                      <th>def</th>
                    </tr>
                    <tr>
                      <td class='left'>123</td>
                      <td id='second'>456</td>
                    </tr>
                  </table>
                  <p class='big'>Title 1</p>
                  The Main Body
sample

      Fracture.define_text(:text_1, "Title 1")
      Fracture.define_text(:text_2, "Main", "Opening")
    end

    let(:nsel_1) { Fracture.define_selector(:nsel_1, "table > td") }
    let(:ntext_1) { Fracture.define_text(:ntext_1, "sex") }
    let(:b11) { Fracture.define_text(:b11, "please") }
    let(:bb1) { Fracture.define_text(:bb1, "Main", "sex") }
    let(:bb2) { Fracture.define_text(:bb2, "Sex", "Main") }
    let(:bb3) { Fracture.define_text(:bb3, "Sex", "please") }

    context "when selector" do
      describe "Fracture" do
        before do
          Fracture.define_selector(:sel_1, "tr>td:contains('123')")
          Fracture.define_selector(:sel_2, "tr>th:contains('abc')", "tr>td:contains('456')")
        end

        it "should find sel_1" do
          Fracture.test_fractures(@page, false, :sel_1).should == {passed: true, should: [], should_not: []}
        end
        it 'should find sel_2' do
          Fracture.test_fractures(@page, false, :sel_2).should == {passed: true, should: [], should_not: []}
        end
        it "should not have sel_1 present" do
          Fracture.test_fractures(@page, true, :sel_1).should == {passed: false,
                                                                  should: [],
                                                                  should_not: [{fracture_label: :sel_1, label: "tr>td:contains('123')"}]}
        end
        it "cant find nsel_1 on page" do
          nsel_1
          Fracture.test_fractures(@page, false, :nsel_1).should == {passed: false,
                                                                    should: [{fracture_label: :nsel_1, :label => "table > td"}],
                                                                    should_not: []}
        end
        it "should not find nsel_1 on page" do
          nsel_1
          Fracture.test_fractures(@page, true, :nsel_1).should == {passed: true,
                                                                   should: [],
                                                                   should_not: []}
        end
      end

      context "have_fracture" do
        it "should find fracture of :class_1" do
          Fracture.define_selector(:class_1, "td.left")
          @page.should have_fracture :class_1
        end
        it "should find fracture of :id_1" do
          Fracture.define_selector(:id_1, "td#second")
          @page.should have_fracture :id_1
        end
        it "should not find missing fracture" do
          Fracture.define_selector(:id_2, "th#second")
          @page.should_not have_fracture :id_2
        end
        it "should fail to find a fracture" do
          Fracture.define_selector(:id_3, "th#second")
          expect { @page.should have_fracture(:id_3) }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected to find 'th#second'/)
        end
      end
    end

    context "when text" do
      describe "Fracture" do
        context "when passing only one fracture list" do
          context "should" do
            context "when 1 fracture" do
              it "1 found" do
                Fracture.test_fractures(@page, false, :text_1).should == {passed: true, should: [], should_not: []}
              end
              it "2 found" do
                Fracture.test_fractures(@page, false, :text_2).should == {passed: true, should: [], should_not: []}
              end
              it "1 not found" do
                ntext_1
                Fracture.test_fractures(@page, false, :ntext_1).should == {passed: false,
                                                                      should: [{fracture_label: :ntext_1, label: "sex"}],
                                                                      should_not: []}
              end
              it "2 not found" do
                bb3
                Fracture.test_fractures(@page, false, :bb3).should == {passed: false,
                                                                       should: [{fracture_label: :bb3, label: "Sex"}, {fracture_label: :bb3, label: "please"}],
                                                                       should_not: []}
              end
              it "1 not found and 1 found" do
                bb1
                Fracture.test_fractures(@page, false, :bb1).should == {passed: false,
                                                                       should: [{fracture_label: :bb1, label: "sex"}],
                                                                       should_not: []}
              end
            end
            context "when list of 2 fractures" do
              it "3 found" do
                Fracture.test_fractures(@page, false, [:text_1, :text_2]).should == {passed: true, should: [], should_not: []}
              end
              it "2 not found" do
                ntext_1
                b11
                Fracture.test_fractures(@page, false, [:ntext_1, :b11]).should == {passed: false,
                                                                              should: [{:fracture_label => :ntext_1, :label => "sex"}, {:fracture_label => :b11, :label => "please"}],
                                                                              should_not: []}
              end
            end
          end
          context "should_not" do
            context "when 1 fracture" do
              it "1 found (not)" do
                Fracture.test_fractures(@page, true, :text_1).should == {passed: false,
                                                                         should_not: [{fracture_label: :text_1, label: "Title 1"}],
                                                                         should: []}
              end
              it "not found" do
                ntext_1
                Fracture.test_fractures(@page, true, :ntext_1).should == {passed: true, should: [], should_not: []}
              end
              it "not found multi" do
                bb3
                Fracture.test_fractures(@page, true, :bb3).should == {passed: true, should: [], should_not: []}
              end
            end
            context "when list of 2 fractures" do
              it "3 found" do
                Fracture.test_fractures(@page, true, [:text_1, :text_2]).should == {passed: false,
                                                                                    should_not: [{:fracture_label => :text_1, :label => "Title 1"},
                                                                                                 {:fracture_label => :text_2, :label => "Main"},
                                                                                                 {:fracture_label => :text_2, :label => "Opening"}],
                                                                                    should: []}
              end
              it "2 not found" do
                ntext_1
                b11
                Fracture.test_fractures(@page, true, [:ntext_1, :b11]).should == {passed: true, should: [], should_not: []}
              end
            end
          end
        end
        context "when passing 2 fracture lists (should find and should not find)" do
          context "should" do
            it "exist 1 found and not exist 1 not found" do
              ntext_1
              Fracture.test_fractures(@page, false, [:text_1], [:ntext_1]).should == {passed: true, should: [], should_not: []}
            end

            it "should not find text_2" do
              Fracture.test_fractures(@page, false, [:text_1], [:text_2]).should == {passed: false, should: [],
                                                                                     should_not: [{:fracture_label => :text_2, :label => "Main"}, {:fracture_label => :text_2, :label => "Opening"}]}
            end
            it "should not find text_1" do
              ntext_1
              Fracture.test_fractures(@page, false, [:ntext_1], [:text_1]).should == {passed: false, should:
                  [{:fracture_label => :ntext_1, :label => "sex"}], should_not: [{fracture_label: :text_1, label: "Title 1"}]}
            end
          end
          context "when should_not" do
            it "should not find ntext_1 and should find text_1 " do
              ntext_1
              Fracture.test_fractures(@page, true, [:ntext_1], [:text_1]).should == {passed: true, should: [], should_not: []}
            end

            it "exist 1 found and not exist 1 not found" do
              ntext_1
              Fracture.test_fractures(@page, true, [:text_1], [:ntext_1]).should == {passed: false,
                                                                                should: [{:fracture_label => :ntext_1, :label => "sex"}],
                                                                                should_not: [{fracture_label: :text_1, label: "Title 1"}]}
            end
            it "text_1 should_not appear on the page and text_2 should" do
              Fracture.test_fractures(@page, true, [:text_1], [:text_2]).should == {passed: false,
                                                                                    should_not: [{fracture_label: :text_1, label: "Title 1"}],
                                                                                    should: []}
            end
          end
        end
        context "have_fracture" do
          context "should" do
            it "match single" do
              @page.should have_fracture(:text_1)
            end
            it "should match multiple" do
              @page.should have_fracture(:text_2)
            end
            it "should not match multiple when 2nd fracture item does not match" do
              bb1
              expect { @page.should have_fracture(:bb1) }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected to find 'sex'/)
            end
            it "should match with multiple arguments" do
              @page.should have_fracture(:text_2, :text_1)
            end
            it "should not match with multiple argument when last item does not match" do
              ntext_1
              expect { @page.should have_fracture(:text_2, :text_1, :ntext_1) }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected to find 'sex'/)
            end
            it "should fail with missing element" do
              ntext_1
              expect { @page.should have_fracture(:ntext_1) }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected to find 'sex'/)
            end
          end
          context "should not" do
            it "fails not match single" do
              expect { @page.should_not have_fracture(:text_1) }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected not to find 'Title 1'/)
            end
            it "should not match multiple when 2nd fracture item does exist" do
              bb2
              expect { @page.should_not have_fracture(:bb2) }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected not to find 'Main'/)
            end
            it "should fail when last fracture has items that exist on pag" do
              bb2
              bb3
              expect { @page.should_not have_fracture(:bb3, :bb2) }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected not to find 'Main'/)
            end
            it "should fail when first fracture has items that exist on pag" do
              bb2
              bb3
              expect { @page.should_not have_fracture([:bb2, :bb3]) }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected not to find 'Main'/)
            end
            it "should pass when no items exist" do
              bb3
              @page.should_not have_fracture(:bb3)
            end
          end
        end
      end
    end

    describe "have_all_fractures" do
      it "all" do
        @page.should have_all_fractures
      end
      it "not have :ntext_1" do
        ntext_1
        expect { @page.should have_all_fractures }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected to find 'sex'/)
      end
      it "not have any fractures" do
        Fracture.clear
        bb3
        @page.should_not have_all_fractures
      end
    end

    describe "have_all_fractures_except" do
      it "should have all except ntext_1" do
        ntext_1
        @page.should have_all_fractures_except :ntext_1
      end
      it "fails when find text_2 on page" do
        expect { @page.should have_all_fractures_except :text_2 }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected not to find 'Main, Opening'/)
      end

      it "fails when should_not finds text_1 on the page" do
        expect { @page.should_not have_all_fractures_except :text_2 }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected not to find 'Title 1'/)
      end

      it "none" do
        Fracture.clear
        Fracture.define_text(:text_1, "Title 1")
        @page.should_not have_all_fractures_except :text_1
      end
    end
    describe "have_only_fractures" do
      it "should have only text_1 and text_2" do
        @page.should have_only_fractures :text_1, :text_2
      end
      it "should have only text_1 and text_2 and ignore ntext_1" do
        ntext_1
        @page.should have_only_fractures :text_1, :text_2
      end
      it "should raise error when one exists" do
        expect { @page.should have_only_fractures :text_2 }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected not to find 'Title 1'/)
      end
      it "should raise error when expected item to exist" do
        ntext_1
        expect { @page.should have_only_fractures :text_1, :text_2, :ntext_1 }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected to find 'sex'/)
      end
    end
  end
end
