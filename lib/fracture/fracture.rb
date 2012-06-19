class Fracture
  attr_accessor :label, :items, :is_text

  def initialize label, items, is_text
    self.label = label
    self.items = Array(items)
    self.is_text = is_text
  end

  def self.define_text label, *items
    @all ||= {}
    @all[label.to_s] = self.new(label, items.flatten, true)
  end

  def self.define_selector label, *items
    @all ||= {}
    @all[label.to_s] = self.new(label, items.flatten, false)
  end

  def text?
    !!is_text
  end

  def self.find labels
    if labels.is_a? Array
      labels.map do |label|
        ret = @all[label.to_s]
        raise "Fracture with Label of '#{label}' was not found" unless ret
      end
    else
      ret = @all[labels.to_s]
      raise "Fracture with Label of '#{labels}' was not found" unless ret
    end
    ret
  end

  def self.all
    @all
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
    #page = page.response.body if page.is_a? CompaniesController
    page = Nokogiri::HTML.parse(page)
    if text?
      page.text.include?(label)
    else
      page.at label
    end
  end

  def self.test_fractures(page, is_not, fracture_labels, reverse_fracture_labels=[])
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
end
