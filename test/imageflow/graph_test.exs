defmodule Imageflow.GraphTest do
  use ExUnit.Case

  alias Imageflow.Graph

  describe "new/0" do
    test "returns a new graph instance" do
      assert %Graph{} = Graph.new()
    end
  end

  describe "decode_file/1" do
    test "appends a new input" do
      graph = Graph.new() |> Graph.decode_file("file.png")

      assert %{io_count: 1, inputs: %{1 => {:file, "file.png"}}} = graph
    end

    test "appends a file decoding operation" do
      graph = Graph.new() |> Graph.decode_file("file.png")

      assert %{nodes: %{1 => %{decode: %{io_id: 1}}}} = graph
    end
  end

  describe "encode_file/1" do
    test "appends a new output" do
      graph = Graph.new() |> Graph.encode_to_file("file.png")

      assert %{io_count: 1, outputs: %{1 => {:file, "file.png"}}} = graph
    end
  end

  describe "constrain/4" do
    test "appends a constrain operation" do
      graph = Graph.new() |> Graph.constrain(10, 20)

      assert %{nodes: %{1 => %{constrain: %{w: 10, h: 20, mode: "within"}}}} = graph
    end

    test "allows overriding the mode" do
      graph = Graph.new() |> Graph.constrain(10, 20, %{mode: "fit"})

      assert %{nodes: %{1 => %{constrain: %{w: 10, h: 20, mode: "fit"}}}} = graph
    end
  end

  describe "region/4" do
    test "appends a region operation" do
      graph = Graph.new() |> Graph.region({1, 2}, {3, 4})

      assert %{
               nodes: %{
                 1 => %{region: %{x1: 1, y1: 2, x2: 3, y2: 4, background_color: "transparent"}}
               }
             } = graph
    end

    test "acepts an optional background color" do
      graph = Graph.new() |> Graph.region({1, 2}, {3, 4}, "FF000000")

      assert %{
               nodes: %{
                 1 => %{region: %{x1: 1, y1: 2, x2: 3, y2: 4, background_color: "FF000000"}}
               }
             } = graph
    end
  end

  describe "region_percent/4" do
    test "appends a region_percent operation" do
      graph = Graph.new() |> Graph.region_percent({1, 2}, {3, 4})

      assert %{
               nodes: %{
                 1 => %{
                   region_percent: %{x1: 1, y1: 2, x2: 3, y2: 4, background_color: "transparent"}
                 }
               }
             } = graph
    end

    test "acepts an optional background color" do
      graph = Graph.new() |> Graph.region_percent({1, 2}, {3, 4}, "FF000000")

      assert %{
               nodes: %{
                 1 => %{
                   region_percent: %{x1: 1, y1: 2, x2: 3, y2: 4, background_color: "FF000000"}
                 }
               }
             } = graph
    end
  end

  describe "crop_whitespace/3" do
    test "appends a crop_whitespace operation" do
      graph = Graph.new() |> Graph.crop_whitespace(1, 2)

      assert %{nodes: %{1 => %{crop_whitespace: %{threshold: 1, percent_padding: 2}}}} = graph
    end
  end

  describe "flip_horizontal/1" do
    test "appends a flip_h operation" do
      graph = Graph.new() |> Graph.flip_horizontal()

      assert %{nodes: %{1 => :flip_h}} = graph
    end
  end

  describe "flip_vertical/1" do
    test "appends a flip_h operation" do
      graph = Graph.new() |> Graph.flip_vertical()

      assert %{nodes: %{1 => :flip_v}} = graph
    end
  end

  describe "transpose/1" do
    test "appends a flip_h operation" do
      graph = Graph.new() |> Graph.transpose()

      assert %{nodes: %{1 => :transpose}} = graph
    end
  end

  describe "rotate_90/1" do
    test "appends a flip_h operation" do
      graph = Graph.new() |> Graph.rotate_90()

      assert %{nodes: %{1 => :rotate_90}} = graph
    end
  end

  describe "rotate_180/1" do
    test "appends a flip_h operation" do
      graph = Graph.new() |> Graph.rotate_180()

      assert %{nodes: %{1 => :rotate_180}} = graph
    end
  end

  describe "rotate_270/1" do
    test "appends a flip_h operation" do
      graph = Graph.new() |> Graph.rotate_270()

      assert %{nodes: %{1 => :rotate_270}} = graph
    end
  end

  describe "fill_rect/4" do
    test "appends a fill_rect operation" do
      graph = Graph.new() |> Graph.fill_rect({1, 2}, {3, 4})

      assert %{nodes: %{1 => %{fill_rect: %{x1: 1, y1: 2, x2: 3, y2: 4, color: "black"}}}} = graph
    end

    test "accepts an optional color" do
      graph = Graph.new() |> Graph.fill_rect({1, 2}, {3, 4}, "red")

      assert %{nodes: %{1 => %{fill_rect: %{x1: 1, y1: 2, x2: 3, y2: 4, color: "red"}}}} = graph
    end
  end

  describe "expand_canvas/6" do
    test "appends a expand_canvas operation" do
      graph = Graph.new() |> Graph.expand_canvas(1, 2, 3, 4)

      assert %{
               nodes: %{
                 1 => %{
                   expand_canvas: %{
                     left: 1,
                     top: 2,
                     right: 3,
                     bottom: 4,
                     color: %{srgb: %{hex: "FFFFFF00"}}
                   }
                 }
               }
             } = graph
    end

    test "accepts an optional color argument" do
      graph = Graph.new() |> Graph.expand_canvas(1, 2, 3, 4, "FF000000")

      assert %{
               nodes: %{
                 1 => %{
                   expand_canvas: %{
                     left: 1,
                     top: 2,
                     right: 3,
                     bottom: 4,
                     color: %{srgb: %{hex: "FF000000"}}
                   }
                 }
               }
             } = graph
    end
  end

  describe "white_balance/2" do
    test "appends a whilte_balance_srgb operation" do
      graph = Graph.new() |> Graph.white_balance(10)

      assert %{nodes: %{1 => %{white_balance_histogram_area_threshold_srgb: %{threshold: 10}}}} =
               graph
    end
  end

  describe "transparency/2" do
    test "appends a color_filter_srgb contrast operation" do
      graph = Graph.new() |> Graph.transparency(10)

      assert %{nodes: %{1 => %{color_filter_srgb: %{alpha: 10}}}} = graph
    end
  end

  describe "contrast/2" do
    test "appends a color_filter_srgb contrast operation" do
      graph = Graph.new() |> Graph.contrast(10)

      assert %{nodes: %{1 => %{color_filter_srgb: %{contrast: 10}}}} = graph
    end
  end

  describe "brightness/2" do
    test "appends a color_filter_srgb contrast operation" do
      graph = Graph.new() |> Graph.brightness(10)

      assert %{nodes: %{1 => %{color_filter_srgb: %{brightness: 10}}}} = graph
    end
  end

  describe "saturation/2" do
    test "appends a color_filter_srgb contrast operation" do
      graph = Graph.new() |> Graph.saturation(10)

      assert %{nodes: %{1 => %{color_filter_srgb: %{saturation: 10}}}} = graph
    end
  end

  describe "color_filter/2" do
    test "appends a generic color_filter_srgb operation" do
      graph = Graph.new() |> Graph.color_filter(%{alpha: 0})

      assert %{nodes: %{1 => %{color_filter_srgb: %{alpha: 0}}}} = graph
    end
  end
end
