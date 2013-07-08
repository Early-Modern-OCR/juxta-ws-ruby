require 'test/unit'
require 'config'
require 'juxta'

class TestSourceURL < Test::Unit::TestCase

  def setup
    # create connection to the service
    @juxta = Juxta.new(JuxtaServicename, JuxtaUsername, JuxtaPassword)
    @url = "http://www.rossettiarchive.org/docs/1-1870.2ndedn.prin.rad.xml"
  end

  def teardown
  end

  # TODO - right now this throws 500
  # def test_invalid_url
  #   begin
  #      @juxta.get_source( "http://dsadsa")
  #   rescue RestClient::BadRequest
  #     # this is expected...
  #   else
  #     assert( false, "Unexpected exception")
  #   end
  # end

  def test_happy_day
    begin
       src_id = @juxta.get_source( @url )
       assert(src_id.nil? == false, "Upload source id is nil" )

       status = @juxta.delete_source(src_id)
       assert( status == true, "File delete failed")
    rescue Exception => e
      assert( false, "Unexpected exception (#{e})")
    end
  end

end
