require "rspec"
require "fracture/fracture"
require 'nokogiri'


describe Fracture do

  before { Fracture.clear }

  context 'define_path' do
    before { Fracture.define_path(:companies, 'companies_path') }
    subject { Fracture.find(:companies) }
    its(:items) { should == ['companies_path'] }
    its(:path?) { should be_true }
  end

  context "without data" do
    it("should be empty before use") { Fracture.all.should == {} }
    it "should not fail when no data set" do
      expect {Fracture.find(:nothing) }.to raise_error(RuntimeError, /No Fractures have been defined/)
    end
  end

  context 'items' do
    context 'items blank on define_selector' do
      it 'should set item to label name starting with #' do
        Fracture.define_selector(:hello).items.should == ['#hello']
      end
    end
    context 'when items set' do
      it 'should set item' do
        Fracture.define_selector(:hello, '#meme').items.should == ['#meme']
      end
      it 'should set multiple items' do
        Fracture.define_selector(:hello, '#meme', '.wtf').items.should == ['#meme', '.wtf']
      end
    end
  end

  context "with data" do
    before do
      @first = Fracture.define_text(:a, "a")
      Fracture.define_text(:bc, "b", "c")
      Fracture.define_selector(:x, "x")
      Fracture.define_selector(:yz, "y", "z")
    end

    describe "#clear" do
      before { Fracture.clear }
      it("should clear all") { Fracture.all.should == {} }
    end

    describe ".text?" do
      it("should be text search") { Fracture.find(:a).text?.should be_true }
      it("should not be text search") { Fracture.find(:x).text?.should be_false }
    end

    context "reuse" do
      context "of same text label" do
        it("should raise error if a label is reused") { expect { Fracture.define_text(:bc, "reused") }.to raise_error(RuntimeError, /bc has already been defined/) }
      end
      context "of same selector label" do
        it("should raise error if a label is reused") { expect { Fracture.define_selector(:x, "reused") }.to raise_error(RuntimeError, /x has already been defined/) }
      end
    end

    context "reuse of same text or selector" do
      it "should display warning when same text is defined"
      it "should display warning when same label is defined"
    end

    describe "#find" do
      context "existing" do
        it("should find label using symbol") { Fracture.find(:a).items == ["a"] }
        it("should find label using string") { Fracture.find("a").items == ["a"] }
      end
      context "should raise error if label does not exist" do
        it("single") { expect { Fracture.find(:ab) }.to raise_error(RuntimeError, /Fracture with Label of 'ab' was not found/) }
      end
    end

    describe "#all" do
      context "should return all Fractures" do
        subject {Fracture.all }
        its(:length) {should == 4}
        its(:keys) {should =~ ["a", "bc", "x", "yz"]}
      end
    end

    #TODO move from matcher_spec
    describe "test_fracture"

    describe ".do_check" do
      it("should find it") { @first.do_check("z a b", "a").should be_true }
      it("should not find it") { @first.do_check("z b", "a").should be_false }
    end
  end

  context 'check if page is html or Controller or Integration class' do
    let(:html) { '<html><body></body></html>' }

    class ControllerTest
      def initialize html
        @html = html
      end

      def response
        self
      end

      def body
        @html
      end
    end

    class IntegrationTest
      def initialize html
        @html = html
      end

      def body
        @html
      end
    end

    describe '#get_body' do
      it('just return html when sent') do
        Fracture.get_body(html).should == html
      end

      it('get response.body from Controller') do
        Fracture.get_body(ControllerTest.new(html)).should == html
      end

      it('get response.body from Integration') do
        Fracture.get_body(IntegrationTest.new(html)).should == html
      end
    end
  end
end
