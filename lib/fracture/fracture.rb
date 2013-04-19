class Fracture
  attr_accessor :label, :items, :is_text

  def initialize label, items, is_text
    self.label = label
    self.items = Array(items)
    self.is_text = is_text
  end

  def self.define_text label, *items
    @all ||= {}
    raise "#{label} has already been defined" if @all[label.to_s]
    @all[label.to_s] = self.new(label, items.flatten, true)
  end

  def self.define_selector label, *items
    @all ||= {}
    raise "#{label} has already been defined" if @all[label.to_s]
    items = ["##{label}"] if items.empty?
    @all[label.to_s] = self.new(label, items.flatten, false)
  end

  def text?
    !!is_text
  end

  def self.find label
    #if labels.is_a? Array
    #  ret = []
    #  labels.map do |label|
    #    p label
    #    ret = all[label.to_s]
    #    raise "Fracture with Label of '#{label}' was not found" unless ret
    #  end
    #  p ret
    #else
      raise "No Fractures have been defined" if all.empty?
      ret = all[label.to_s]
      raise "Fracture with Label of '#{label}' was not found" unless ret
    #end
    ret
  end

  def self.all
    @all || {}
  end

  def self.clear
    @all = {}
  end

  def self.list_to_s items
    items.map { |item| item.to_s }
  end

  def self.have_only_test page, is_not, only_fractures
    test_fractures page, is_not, only_fractures, all_keys_less(only_fractures)
  end

  def self.have_all_except_test page, is_not, except_fractures
    test_fractures page, is_not, all_keys_less(except_fractures), except_fractures
  end

  def self.all_keys_less fractures
    all.keys - list_to_s(Array(fractures).flatten)
  end

  def do_check page, label
    page_parsed = Nokogiri::HTML.parse(page)

    if text?
      page_parsed.text.include?(label)
    else
      page_parsed.at label
    end
  end

  def self.test_fractures(page, is_not, fracture_labels, reverse_fracture_labels=[])
    page = self.get_body(page)
    failures = {}
    failures[:should] = []
    failures[:should_not] = []
    Array(fracture_labels).flatten.each do |fracture_label|
      fracture = Fracture.find(fracture_label)
      fracture.items.each do |label|
        if is_not
          if fracture.do_check(page, label)
            failures[:should_not] << {fracture_label: fracture_label, label: label}
          end
        else
          unless fracture.do_check(page, label)
            failures[:should] << {fracture_label: fracture_label, label: label}
          end
        end
      end
    end
    Array(reverse_fracture_labels).flatten.each do |fracture_label|
      fracture = Fracture.find(fracture_label)
      fracture.items.each do |label|
        unless is_not
          if fracture.do_check(page, label)
            failures[:should_not] << {fracture_label: fracture_label, label: label}
          end
        else
          unless fracture.do_check(page, label)
            failures[:should] << {fracture_label: fracture_label, label: label}
          end
        end
      end
    end
    failures.merge!(passed: (failures[:should].empty? && failures[:should_not].empty?))
    failures
  end

  def self.get_body(page)
    case
      when page.respond_to?(:response) # Controller
        page.response.body
      when page.respond_to?(:body)
        page.body
      when page.kind_of?(String)
        page
      else
        raise 'Page sent is not valid'
    end
  end
end
