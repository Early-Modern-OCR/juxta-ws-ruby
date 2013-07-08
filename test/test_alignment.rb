require 'test/unit'
require 'config'
require 'juxta'

class TestAlignment < Test::Unit::TestCase
   def setup
      # create connection to the service
      @juxta = Juxta.new(JuxtaServicename, JuxtaUsername, JuxtaPassword)

      # create a standardized file set...
      @file_set = standard_fileset( )

      begin
         # make the witness set...
         @src_ids, @wit_ids, @set_id = @juxta.create_witness_set( @file_set )
         assert( @src_ids.length != 0, "Zero length source list" )
         assert( @wit_ids.length != 0, "Zero length witness list" )
         assert( @src_ids.length == @wit_ids.length, "Differing size asset lists" )
      rescue Exception => e
         assert( false, "Unexpected exception (#{e})")
      end

   end

   def teardown
      begin
         # destroy witness set
         status = @juxta.destroy_witness_set( @src_ids, @wit_ids )
         assert( status == true, "Failed to destroy witness set" )
         
         # delete the witness set
         status = @juxta.delete_set( @set_id )
         assert( status == true, "Failed to delete witness set" )         
      rescue Exception => e
         assert( false, "Unexpected exception (#{e})")
      end
   end

   def test_list_alignments_bad_set_id
      begin
         @juxta.list_alignments( "bad-set-id" )
      rescue RestClient::BadRequest
         # this is expected...
      else
         assert( false, "Unexpected exception")
      end
   end

   def test_list_alignment_missing_set_id
      begin
         @juxta.list_alignments( "0000" )
      rescue RestClient::ResourceNotFound
         # this is expected...
      else
         assert( false, "Unexpected exception")
      end
   end

   def test_delete_alignment_bad_id
      begin
         @juxta.delete_alignment( @set_id, "bad-alignment-id" )
      rescue RestClient::BadRequest
         # this is expected...
      else
         assert( false, "Unexpected exception")
      end
   end

   def test_delete_alignment_mising_id
      begin
         @juxta.delete_alignment( @set_id, "0000" )
      rescue RestClient::ResourceNotFound
         # this is expected...
      else
         assert( false, "Unexpected exception")
      end
   end
   
   def test_malformed_create_alignment
      begin
         json = "broken"
         resp = @juxta.create_alignment( @set_id, json )
         align_id = resp.gsub(/\[/, '').gsub(/\]/, '')
         assert( align_id.length != 0, "Invalid create alignment response" )

         # get the annotation list
         annotation_list = @juxta.list_annotations( @set_id, @wit_ids[ 0 ] )
         assert( annotation_list.length != 0, "Zero length annotation list" )
      rescue RestClient::BadRequest
         # this is expected...
      else
         assert( false, "Unexpected exception")
      end
   end
   
   def test_incomplete_create_alignment
      begin
         json = [ { :editDistance => 5, :annotations=>[1,2]}]
         resp = @juxta.create_alignment( @set_id, json )
         align_id = resp.gsub(/\[/, '').gsub(/\]/, '')
         assert( align_id.length != 0, "Invalid create alignment response" )

         # get the annotation list
         annotation_list = @juxta.list_annotations( @set_id, @wit_ids[ 0 ] )
         assert( annotation_list.length != 0, "Zero length annotation list" )
      rescue RestClient::BadRequest
         # this is expected...
      else
         assert( false, "Unexpected exception")
      end
   end
   
   def test_incomplete_anno_create_alignment
      begin
         json = [ { :name => { :namespace => "http://juxtasoftware.org/ns", :localName => "token"}, :range => {:start=>0,:end=>10}}]
         resp = @juxta.create_annotation( @set_id, @wit_ids[0], json )
         anno_1 = resp.gsub(/\[/, '').gsub(/\]/, '')
         assert( anno_1.length != 0, "Invalid create annotation response" )
         
         json = [ { :name => { :namespace => "http://juxtasoftware.org/ns", :localName => "change"}, :editDistance => 5, :annotations=>[anno_1]}]
         resp = @juxta.create_alignment( @set_id, json )
         align_id = resp.gsub(/\[/, '').gsub(/\]/, '')
         assert( align_id.length != 0, "Invalid create alignment response" )

         # get the annotation list
         annotation_list = @juxta.list_annotations( @set_id, @wit_ids[ 0 ] )
         assert( annotation_list.length != 0, "Zero length annotation list" )
      rescue RestClient::BadRequest
         # this is expected...
      else
         assert( false, "Unexpected exception")
      end
   end
   
   def test_missing_anno_create_alignment
      begin
         json = [ { :name => { :namespace => "http://juxtasoftware.org/ns", :localName => "change"}, :editDistance => 5, :annotations=>[0,0]}]
         resp = @juxta.create_alignment( @set_id, json )
         align_id = resp.gsub(/\[/, '').gsub(/\]/, '')
         assert( align_id.length != 0, "Invalid create alignment response" )

         # get the annotation list
         annotation_list = @juxta.list_annotations( @set_id, @wit_ids[ 0 ] )
         assert( annotation_list.length != 0, "Zero length annotation list" )
      rescue RestClient::BadRequest
         # this is expected...
      else
         assert( false, "Unexpected exception")
      end
   end


   def test_good_create_alignment
      begin         
         # create alignment between new annotations
         json = [ { :name => { :namespace => "http://juxtasoftware.org/ns", :localName => "change"}, :editDistance => 5, 
                    :annotations=>[
                       { :witnessId=>@wit_ids[0], :name => { :namespace => "http://juxtasoftware.org/ns", :localName => "token"}, :range => {:start=>0,:end=>10}},
                       { :witnessId=>@wit_ids[1], :name => { :namespace => "http://juxtasoftware.org/ns", :localName => "token"}, :range => {:start=>0,:end=>9}}
                    ]}]
         resp = @juxta.create_alignment( @set_id, json )
         assert( resp != 1, "Incorrect resonse to create alignment; wrong number of alignments created." )

         # get the alignment list
         align_list = @juxta.list_alignments( @set_id )
         assert( align_list.length == 1, "Missing alignment in list" )
      rescue Exception => e
         assert( false, "Unexpected exception (#{e})")
      end
   end
   
   def test_good_list_alignments
      begin
         # tokenize...
         status = @juxta.tokenize_set( @set_id )
         assert( status == true, "Failed to tokenize witness set" )
         
         # collate...
         status = @juxta.collate_set( @set_id )
         assert( status == true, "Failed to collate witness set" )

         alignment_list = @juxta.list_alignments( @set_id )
         assert( alignment_list.length != 0, "Zero length alignment list" )

      rescue Exception => e
         assert( false, "Unexpected exception (#{e})")
      end
   end
   
   
   def test_good_delete_alignments
      begin
         # tokenize...
         status = @juxta.tokenize_set( @set_id )
         assert( status == true, "Failed to tokenize witness set" )
         
         # collate...
         status = @juxta.collate_set( @set_id )
         assert( status == true, "Failed to collate witness set" )

         # get the alignment list
         alignment_list = @juxta.list_alignments( @set_id )
         assert( alignment_list.length != 0, "Zero length alignment list" )

         # delete the first and last one...
         status = @juxta.delete_alignment( @set_id, alignment_list[ 0 ]['id'] )
         assert( status == true, "Failed to delete alignment" )
         status = @juxta.delete_alignment( @set_id, alignment_list[ alignment_list.length - 1 ]['id'] )
         assert( status == true, "Failed to delete alignment" )

      rescue Exception => e
         assert( false, "Unexpected exception (#{e})")
      end
   end

end
