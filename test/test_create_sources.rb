require 'test/unit'
require 'config'
require 'juxta'

class TestCreateSources < Test::Unit::TestCase

  def setup
    # create connection to the service
    @juxta = Juxta.new(JuxtaServicename, JuxtaUsername, JuxtaPassword)
    @witness_a = "It was the best of times, it was the worst of times."
    @witness_b = "<html><p>It was the best of times, it was the blurst of times.</p></html>"
  end

  def teardown
  end

  def test_happy_day
    begin
       source_array = [ { name: 'a', type: 'raw', contentType: 'txt', data: @witness_a }, 
                        { name: 'b', type: 'raw', contentType: 'xml', data: @witness_b } ]
      
       srcs = @juxta.create_sources( source_array )
       assert(srcs.nil? == false, "Created source id is nil" )
       assert( srcs.length == 2, "Should have returned two source ids" )

       srcs.each { |src| 
         status = @juxta.delete_source(src)
         assert( status == true, "Source delete failed")
       }
    rescue Exception => e
      assert( false, "Unexpected exception (#{e})")
    end
  end

end
