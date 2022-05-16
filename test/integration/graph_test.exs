defmodule Imageflow.Integration.GraphTest do
  use ExUnit.Case

  alias Imageflow.{Native}

  @input_path "test/fixtures/elixir-logo.jpg"
  @output_path "/tmp/output.png"

  test "can pipe multiple operations" do
    assert {:ok, %{"/tmp/output.png" => :ok}} =
             Imageflow.new()
             |> Imageflow.from_file(@input_path)
             |> Imageflow.constrain(20, 20)
             |> Imageflow.rotate_270()
             |> Imageflow.transpose()
             |> Imageflow.color_filter("invert")
             |> Imageflow.to_file(@output_path)
             |> Imageflow.run()
  end

  test "can generate multiple images" do
    Imageflow.new()
    |> Imageflow.from_file(@input_path)
    |> Imageflow.branch(fn flow ->
      flow
      |> Imageflow.constrain(20, nil)
      |> Imageflow.to_file("/tmp/20x20.png")
    end)
    |> Imageflow.branch(fn flow ->
      flow
      |> Imageflow.constrain(nil, 10)
      |> Imageflow.to_file("/tmp/10x10.png")
    end)
    |> Imageflow.run()

    job = Native.create!()
    :ok = Native.add_input_file(job, 0, "/tmp/20x20.png")
    {:ok, resp} = Native.message(job, "v0.1/get_image_info", %{io_id: 0})

    assert get_in(resp, ["data", "image_info", "image_width"]) == 20

    job = Native.create!()
    :ok = Native.add_input_file(job, 0, "/tmp/10x10.png")
    {:ok, resp} = Native.message(job, "v0.1/get_image_info", %{io_id: 0})

    assert get_in(resp, ["data", "image_info", "image_height"]) == 10
  end

  test "can handle multiple operations" do
    assert {:ok, %{"/tmp/rotated.png" => :ok}} =
             Imageflow.new()
             |> Imageflow.from_file(@input_path)
             |> Imageflow.flip_vertical()
             |> Imageflow.transpose()
             |> Imageflow.to_file("/tmp/rotated.png")
             |> Imageflow.run()
  end
end
