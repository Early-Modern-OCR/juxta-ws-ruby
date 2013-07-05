require 'test/unit'
require 'juxta'

class TestXSLT < Test::Unit::TestCase
   def setup
     @juxta = Juxta.new("http://127.0.0.1:8182")
      @dummxslt =
    '<?xml version="1.0"?><xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"><xsl:template match="/"></xsl:template></xsl:stylesheet>'
   end

   def teardown
   end

   def test_post_xslt
      begin
         json = {:name=>make_guid, :xslt=>@dummxslt }
         resp = @juxta.create_xslt( json )
         assert( resp.length != 0, "Blank response" )

         @juxta.delete_asset( "xslt/#{resp}" )
      rescue Exception => e
         assert( false, "Unexpected exception")
      end
   end
   
   def test_post_bad_xslt
      begin
         json = {:xslt=>@dummxslt }
         resp = @juxta.create_xslt( json )
         assert(false, "accepted bad xslt post" )

         @juxta.delete_asset( "xslt/#{resp}" )
      rescue RestClient::BadRequest
         # expected
      else
         assert( false, "Unexpected exception")
      end
   end

   def test_good_get_xslt_list
      begin
         json = {:name=>make_guid, :xslt=>@dummxslt }
         resp = @juxta.create_xslt( json )
         assert( resp.length != 0, "Blank response" )
         
         xslts = @juxta.list_xslt(  )
         assert( xslts.size != 0, "Empty XSLT list" )
         
         @juxta.delete_asset( "xslt/#{resp}" )
      rescue Exception => e
         assert( false, "Unexpected exception (#{e})")
      end
   end

   def test_missing_get_xslt
      begin
         xslt = 99999999
         @juxta.get_xslt( xslt )
      rescue RestClient::ResourceNotFound
      # this is expected...
      else
         assert( false, "Unexpected exception")
      end
   end

end
