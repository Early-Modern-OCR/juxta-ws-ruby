require 'test/unit'
require 'juxta'

class TestWorkspace < Test::Unit::TestCase

  def setup
    @url = "http://127.0.0.1:8182"
  end

  def teardown
  end

  def test_good_create_workspace
    begin
        juxta = Juxta.new(@url)
        workspace = make_guid( )
        workspace_id = juxta.create_workspace( workspace )
        assert( workspace_id.nil? == false, "nil workspace ID")
        juxta.delete_workspace( workspace )
     rescue Exception => e
        assert( false, "Unexpected exception (#{e})")
     end
  end

  def test_bad_create_workspace
    begin
      juxta = Juxta.new(@url)
      workspace = "x" * 2048
      workspace_id = juxta.create_workspace( workspace )
    rescue RestClient::BadRequest
      # this is expected...
    else
      assert( false, "Unexpected exception")
    end
  end
  
  def test_good_delete_workspace
    begin
      juxta = Juxta.new(@url)
      workspace = make_guid( )
      workspace_id = juxta.create_workspace( workspace )
      assert( workspace_id.nil? == false, "nil workspace ID")
      status = juxta.delete_workspace( workspace )
      assert( status == true, "Failed to delete workspace" )
    rescue Exception => e
      assert( false, "Unexpected exception (#{e})")
    end
  end
  
  def test_missing_delete_workspace
    begin
      juxta = Juxta.new(@url)
      workspace = make_guid( )
      status = juxta.delete_workspace( workspace )
    rescue RestClient::ResourceNotFound
      # this is expected...
    else
      assert( false, "Unexpected exception")
    end
  end
  
  def test_list_workspace
    begin
      juxta = Juxta.new(@url)
      workspaces = juxta.list_workspaces()
      assert( workspaces.size != 0, "Empty workspace list" )
    rescue Exception => e
      assert( false, "Unexpected exception (#{e})")
    end
  end

end
