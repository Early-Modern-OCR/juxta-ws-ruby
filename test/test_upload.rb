require 'test/unit'
require 'juxta'

class TestUpload < Test::Unit::TestCase

  def setup
    # create connection to the service
    @juxta = Juxta.new("http://127.0.0.1:8182")
    @filename = "test/good-testdata/dgr.ltr.0558.rad.xml"
  end

  def teardown
  end

  def test_empty_file
    begin
       @juxta.upload_source( "test/bad-testdata/empty.xml")
    rescue RestClient::BadRequest
      # this is expected...
    else
      assert( false, "Unexpected exception")
    end
  end

  def test_oversize_file
     begin
        @juxta.upload_source( "test/bad-testdata/moby-dick/MD_Amer.xml")
     rescue Exception => e
        # this is expected...
     else
       assert( false, "Unexpected exception")
     end
  end

  def test_corrupt_file
    begin
       @juxta.upload_source( "test/bad-testdata/corrupt.xml")
    rescue RestClient::BadRequest
       # this is expected...
    else
       assert( false, "Unexpected exception")
    end
  end

  def test_happy_day
    begin
       src_id = @juxta.upload_source( @filename )
       assert(src_id.nil? == false, "Upload source id is nil" )

       status = @juxta.delete_source( src_id)
       assert( status == true, "File delete failed")
    rescue Exception => e
      assert( false, "Unexpected exception (#{e})")
    end
  end

end
