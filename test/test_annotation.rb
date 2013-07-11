require 'test/unit'
require 'config'
require 'juxta'

class TestAnnotation < Test::Unit::TestCase
   def setup
      # create connection to the service
      @juxta = Juxta.new(JuxtaServicename, JuxtaUsername, JuxtaPassword)

      # create a standardized file set...
      @file_set = standard_fileset( )

      begin
         # make the witness set...
         @src_ids, @wit_ids, @set_id = @juxta.create_witness_set(  @file_set )
         assert( @src_ids.length != 0, "Zero length source list" )
         assert( @wit_ids.length != 0, "Zero length witness list" )
         assert( @src_ids.length == @wit_ids.length, "Differing size asset lists" )
      rescue Exception => e
         assert( false, "Unexpected exception (#{e})")
      end

   end

   def teardown
      begin         
         # delete the witness set
         status = @juxta.delete_set(  @set_id )
         assert( status == true, "Failed to delete witness set" )
                  
      rescue Exception => e
         assert( false, "Unexpected exception (#{e})")
      end
   end

   def test_list_annotations_bad_set_id
      begin
         @juxta.list_annotations(  "bad-set-id", "0000" )
      rescue RestClient::BadRequest
         # this is expected...
      else
         assert( false, "Unexpected exception")
      end
   end

   def test_list_annotations_missing_set_id
      begin
         @juxta.list_annotations(  "0000", "0000" )
      rescue RestClient::ResourceNotFound
         # this is expected...
      else
         assert( false, "Unexpected exception")
      end
   end

   def test_list_annotations_bad_witness_id
      begin
         @juxta.list_annotations(  @set_id, "bad-witness-id" )
      rescue RestClient::BadRequest
         # this is expected...
      else
         assert( false, "Unexpected exception")
      end
   end

   def test_list_annotations_missing_witness_id
      begin
         @juxta.list_annotations(  @set_id, "0000" )
      rescue RestClient::ResourceNotFound
         # this is expected...
      else
         assert( false, "Unexpected exception")
      end
   end

   def test_delete_annotation_bad_id
      begin
         @juxta.delete_annotation(  @set_id, @wit_ids[ 0 ],"bad-annotation-id" )
      rescue RestClient::BadRequest
         # this is expected...
      else
         assert( false, "Unexpected exception")
      end
   end

   def test_delete_annotation_mising_id
      begin
         @juxta.delete_annotation(  @set_id, @wit_ids[ 0 ], "0000" )
      rescue RestClient::ResourceNotFound
         # this is expected...
      else
         assert( false, "Unexpected exception")
      end
   end

   def test_good_create_annotations
      begin
         json = [ { :name => { :namespace => "http://juxtasoftware.org/ns", :localName => "token"}, :range => {:start=>0,:end=>10}}]
         resp = @juxta.create_annotations( @set_id, @wit_ids[0], json )
         assert( resp != 1, "Invalid create annotation response" )

         # get the annotation list
         annotation_list = @juxta.list_annotations(  @set_id, @wit_ids[ 0 ] )
         assert( annotation_list.length != 0, "Zero length annotation list" )
      rescue Exception => e
         assert( false, "Unexpected exception (#{e})")
      end
   end

   def test_bad_create_annotations
      begin
         json = [ { :name => { :namespace => "http://juxtasoftware.org/ns", :localName => "token"} }]
         resp = @juxta.create_annotations( @set_id, @wit_ids[0], json)
         assert( false, "Bad annotation accepted")

         json = "WRONG"
         resp = @juxta.create_annotations( @set_id, @wit_ids[0], json )
         assert( false, "Bad annotation accepted")
      rescue RestClient::BadRequest
         # expected
      else
         assert( false, "Unexpected exception")
      end
   end

   def test_good_delete_annotations
      begin
         # tokenize...
         status = @juxta.tokenize_set(  @set_id )
         assert( status == true, "Failed to tokenize witness set" )

         # get the annotation list
         annotation_list = @juxta.list_annotations(  @set_id, @wit_ids[ 0 ] )
         assert( annotation_list.length != 0, "Zero length annotation list" )

         # delete the first and last one...
         status = @juxta.delete_annotation(  @set_id, @wit_ids[ 0 ], annotation_list[ 0 ]['id'] )
         assert( status == true, "Failed to delete annotation" )
                  
         status = @juxta.delete_annotation(  @set_id, @wit_ids[ 0 ], annotation_list[ annotation_list.length - 1 ]['id'] )
         assert( status == true, "Failed to delete annotation" )

      rescue Exception => e
         assert( false, "Unexpected exception (#{e})")
      end
   end

   def test_good_list_annotations
      begin
         # tokenize...
         status = @juxta.tokenize_set(  @set_id )
         assert( status == true, "Failed to tokenize witness set" )

         annotation_list = @juxta.list_annotations(  @set_id, @wit_ids[ 0 ] )
         assert( annotation_list.length != 0, "Zero length annotation list" )

      rescue Exception => e
         assert( false, "Unexpected exception (#{e})")
      end
   end

end
