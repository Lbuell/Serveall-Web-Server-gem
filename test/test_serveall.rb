require 'test/unit'
require 'serveall'

class Serveall < Test::Unit::TestCase
  def test_english_hello
    assert_equal "hello world",
      Serveall.hi("english")
  end

  def test_any_hello
    assert_equal "hello world",
      Serveall.hi("ruby")
  end

  def test_spanish_hello
    assert_equal "hola mundo",
      Servall.hi("spanish")
  end
end
