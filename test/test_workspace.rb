require 'test/unit'
require 'config'
require 'juxta'

class TestWorkspace < Test::Unit::TestCase

  def setup
    @juxta = Juxta.new(JuxtaServicename, JuxtaUsername, JuxtaPassword)
  end

  def teardown
  end

  def test_select_workspace
    # workspace should be public by default
    assert( @juxta.workspace == "public", "workspace should be public by default" )

    # create test workspace 
    workspace = make_guid( )
    @juxta.create_workspace( workspace )
    
    # select should return true if there is a workspace by that name
    assert( @juxta.select_workspace( workspace ), "should be able to select the created workspace" )
    
    # delete test workspace 
    @juxta.delete_workspace( workspace )
    
    # should be able to switch to public but not back to deleted workspace
    assert( @juxta.select_workspace( "public" ), "should be able to select the public workspace" )
    assert( !@juxta.select_workspace( workspace ), "should not be able to select deleted workspace" )  
  end

  def test_good_create_workspace
    begin
        workspace = make_guid( )
        workspace_id = @juxta.create_workspace( workspace )
        assert( workspace_id.nil? == false, "nil workspace ID")
        @juxta.delete_workspace( workspace )
     rescue Exception => e
        assert( false, "Unexpected exception (#{e})")
     end
  end

  def test_bad_create_workspace
    begin
      workspace = "x" * 2048
      workspace_id = @juxta.create_workspace( workspace )
    rescue RestClient::BadRequest
      # this is expected...
    else
      assert( false, "Unexpected exception")
    end
  end
  
  def test_good_delete_workspace
    begin
      workspace = make_guid( )
      workspace_id = @juxta.create_workspace( workspace )
      assert( workspace_id.nil? == false, "nil workspace ID")
      status = @juxta.delete_workspace( workspace )
      assert( status == true, "Failed to delete workspace" )
    rescue Exception => e
      assert( false, "Unexpected exception (#{e})")
    end
  end
  
  def test_missing_delete_workspace
    begin
      workspace = make_guid( )
      status = @juxta.delete_workspace( workspace )
    rescue RestClient::ResourceNotFound
      # this is expected...
    else
      assert( false, "Unexpected exception")
    end
  end
  
  def test_list_workspace
    begin
      workspaces = @juxta.list_workspaces()
      assert( workspaces.size != 0, "Empty workspace list" )
    rescue Exception => e
      assert( false, "Unexpected exception (#{e})")
    end
  end

end
