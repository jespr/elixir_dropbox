defmodule ElixirDropboxTest do
  use ExUnit.Case
  doctest ElixirDropbox

  setup_all do
    access_token = System.get_env "DROPBOX_ACCESS_TOKEN"
    client = ElixirDropbox.Client.new(access_token)
    {:ok, [ client: client ]}
  end

  test "get current account", state do
  	current_account = ElixirDropbox.Users.current_account(state[:client])
  	assert current_account["account_id"] != nil
  end

  test "get space usage", state do
    space_usage = ElixirDropbox.Users.get_space_usage(state[:client])
    assert space_usage["used"] != nil
  end

  test "get metadata", state do
  	folder = ElixirDropbox.Files.create_folder(state[:client], "/test")
  	metadata = ElixirDropbox.Files.get_metadata(state[:client], "/test")
  	assert metadata[".tag"] == "folder"
  	assert folder["id"] == metadata["id"]
  end

  test "list folder contents", state do
    ElixirDropbox.Files.create_folder(state[:client], "/upload_test")
    files = ["file1.txt", "file2.txt", "file1.pdf", "file2.pdf"]
    |> Enum.each(fn(fln) -> 
      ElixirDropbox.Files.upload(state[:client], "/upload_test/#{fln}", "test/fixtures/#{fln}")
    end)
    assert ["/upload_test/file1.txt", "/upload_test/file2.txt"] == ElixirDropbox.Files.list_filenames_in_folder(state[:client], "/upload_test", "txt")
    assert ["/upload_test/file1.pdf", "/upload_test/file2.pdf"] == ElixirDropbox.Files.list_filenames_in_folder(state[:client], "/upload_test", "pdf")
  end  

  test "create folder", state do
    folder = ElixirDropbox.Files.create_folder(state[:client], "/hello_world")
    assert folder["name"] == "hello_world"
  end
  
  test "delete folder", state do
    folder = ElixirDropbox.Files.create_folder(state[:client], "/deleted_folder")
    deleted_folder = ElixirDropbox.Files.delete_folder(state[:client], "/deleted_folder")
    assert deleted_folder["name"] == "deleted_folder"
  end
end
