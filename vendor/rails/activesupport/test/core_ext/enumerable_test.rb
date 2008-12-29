require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/active_support/core_ext/enumerable'

class EnumerableTests < Test::Unit::TestCase
  
  def test_first_match_no_match
    [[1, 2, 3, 4, 5], (1..9)].each {|a| a.first_match {|x| x > 10}}
  end
  
  def test_first_match_with_match
    assert_equal true, [1, 2, 3, 4, 5, 6].first_match {|x| x > 4}
    assert_equal true, (1..10).first_match {|x| x > 9}
    assert_equal :aba, {:a => 10, :aba => 50, :bac => 40}.first_match {|k, v| k if v > 45}
  end

  def test_group_by
    names = %w(marcel sam david jeremy)
    klass = Class.new
    klass.send(:attr_accessor, :name)
    objects = (1..50).inject([]) do |people,| 
      p = klass.new
      p.name = names.sort_by { rand }.first
      people << p
    end

    objects.group_by {|object| object.name}.each do |name, group|
      assert group.all? {|person| person.name == name}
    end
  end
end
