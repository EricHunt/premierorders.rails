require 'util/functions'

module Option
  include Enumerable

  def self.new(value)
    value.nil? ? None::NONE : Some.new(value)
  end

  def self.some(value)
    Some.new(value)
  end

  def self.none
    None::NONE
  end

  def self.iif(bool, &value)
    bool ? Option.new(value.call) : None::NONE
  end

  def self.call(sym, obj)
    obj.respond_to?(sym) ? Option.new(obj.send(sym)) : None::NONE
  end

  def self.fromString(value)
    value.nil? ? None::NONE : (value.strip.empty? ? None::NONE : Some.new(value))
  end

  def any?(&f)
    cata(f, false)
  end

  def bind(&f)
    cata(f, None::NONE)
  end

  def contains?(v)
    cata(lambda {|a| v eql? a}, false)
  end

  def empty?
    cata(lambda {|a| false}, true)
  end

  def inject(v, &block)
    cata(lambda {|a| block.call(v, a)}, v)
  end

  def map(&f)
    cata(lambda {|a| Some.new(f.call(a))}, None::NONE)
  end

  # This is like map, except that null values returned from the applied
  # function result in equivalent behavior to calling bind(_ => None::NONE)
  def mapn(&f)
    cata(lambda {|a| Option.new(f.call(a))}, None::NONE)
  end

  def to_a
    cata(lambda {|a| [a]}, [])
  end

  def orSome(default)
    cata(Functions::IDENTITY, default)
  end

  def orLazy(&f)
    cata(Functions::IDENTITY, f.call)
  end

  def orElse(opt)
    cata(lambda{|a| self}, opt)
  end

  def orElseLazy(&f)
    cata(lambda{|a| self}, f.call)
  end

  alias_method :each, :map
end

class Some
  include Option
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def cata(f, default)
    f.call(@value)
  end

  def inspect
    "Some(#{@value.inspect})"
  end

  def to_s
    @value.to_s
  end
end

class None
  include Option

  NONE = None.new

  def cata(f, default)
    default
  end

  def inspect
    "None"
  end

  alias_method :to_s, :inspect
end

