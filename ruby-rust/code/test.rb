require 'fiddle'
require 'fiddle/struct'
require 'minitest/autorun'

module Simple
  extend self

  def add_one(int)
    fn_add_one.call(int)
  end

  def head(array)
    packed = IntArray.malloc
    packed.length = array.length
    packed.members = array.pack('l*')
    fn_head.call(packed)
  end

  def tail(array)
    packed = IntArray.malloc
    packed.length = array.length
    packed.members = array.pack('l*')
    pointer = fn_tail.call(packed)
    unpacked = IntArray.new(pointer)
    unpacked.members[0, Fiddle::SIZEOF_INT * unpacked.length].unpack('l*')
  end

  private

  IntArray = Fiddle::CStructBuilder.create(
    Fiddle::CStruct,
    [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP],
    ['length', 'members']
  )
 
  def lib
    @lib ||= begin      
      path = Dir[File.expand_path('../simple/target/release/libsimple.{dll,dylib,so}', __FILE__)].first
      Fiddle.dlopen(path)
    end
  end

  def fn_add_one
    @fn_add_one ||= Fiddle::Function.new(lib['add_one'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
  end

  def fn_head
    @fn_head ||= Fiddle::Function.new(lib['head'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  end

  def fn_tail
    @fn_tail ||= Fiddle::Function.new(lib['tail'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOIDP)
  end
end

class TestSimple < Minitest::Unit::TestCase
  def test_add_one
    assert_equal(6, Simple.add_one(5))
  end

  def test_head
    assert_equal(3, Simple.head([3, 2, 1]))
  end

  def test_tail
    assert_equal([4, 5], Simple.tail([3, 4, 5]))
  end
end
