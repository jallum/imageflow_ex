defmodule Imageflow.Test do
  use ExUnit.Case

  describe "new/0" do
    test "returns a new flow instance" do
      assert %Imageflow{} = Imageflow.new()
    end
  end

  describe "from_file/1" do
    test "appends a new input" do
      flow = Imageflow.new() |> Imageflow.from_file("file.png")

      assert %{io_count: 1, inputs: %{1 => {:file, "file.png"}}} = flow
    end

    test "appends a file decoding operation" do
      flow = Imageflow.new() |> Imageflow.from_file("file.png")

      assert %{nodes: %{1 => %{decode: %{io_id: 1}}}} = flow
    end
  end

  describe "to_file/1" do
    test "appends a new output" do
      flow = Imageflow.new() |> Imageflow.to_file("file.png")

      assert %{io_count: 1, outputs: %{1 => {:file, "file.png"}}} = flow
    end

    test "appends a file encoding operation" do
      flow = Imageflow.new() |> Imageflow.to_file("file.png")

      assert %{nodes: %{1 => %{encode: %{io_id: 1}}}} = flow
    end

    test "allows appending jpg outputs" do
      flow = Imageflow.new() |> Imageflow.to_file("file.jpg", :jpg)

      assert %{nodes: %{1 => %{encode: %{io_id: 1, preset: %{mozjpeg: %{quality: 90}}}}}} = flow
    end

    test "allows appending jpg outputs with custom parameters" do
      flow = Imageflow.new() |> Imageflow.to_file("file.jpg", :jpg, %{quality: 10})

      assert %{nodes: %{1 => %{encode: %{io_id: 1, preset: %{mozjpeg: %{quality: 10}}}}}} = flow
    end

    test "allows appending png outputs" do
      flow = Imageflow.new() |> Imageflow.to_file("file.jpg", :png)

      assert %{
               nodes: %{
                 1 => %{encode: %{io_id: 1, preset: %{lodepng: %{maximum_deflate: false}}}}
               }
             } = flow
    end

    test "allows appending png outputs with custom parameters" do
      flow = Imageflow.new() |> Imageflow.to_file("file.jpg", :png, %{maximum_deflate: true})

      assert %{
               nodes: %{1 => %{encode: %{io_id: 1, preset: %{lodepng: %{maximum_deflate: true}}}}}
             } = flow
    end

    test "allows appending gif outputs" do
      flow = Imageflow.new() |> Imageflow.to_file("file.gif", :gif)

      assert %{nodes: %{1 => %{encode: %{io_id: 1, preset: :gif}}}} = flow
    end

    test "allows appending gif outputs with custom parameters" do
      flow = Imageflow.new() |> Imageflow.to_file("file.jpg", :gif, %{a: :b})

      assert %{nodes: %{1 => %{encode: %{io_id: 1, preset: :gif}}}} = flow
    end

    test "allows appending webp outputs" do
      flow = Imageflow.new() |> Imageflow.to_file("file.webp", :webp)

      assert %{nodes: %{1 => %{encode: %{io_id: 1, preset: :webplossless}}}} = flow
    end

    test "allows appending webp outputs with custom parameters" do
      flow = Imageflow.new() |> Imageflow.to_file("file.webp", :webp, %{a: :b})

      assert %{nodes: %{1 => %{encode: %{io_id: 1, preset: :webplossless}}}} = flow
    end
  end

  describe "constrain/4" do
    test "appends a constrain operation" do
      flow = Imageflow.new() |> Imageflow.constrain(10, 20)

      assert %{nodes: %{1 => %{constrain: %{w: 10, h: 20, mode: "within"}}}} = flow
    end

    test "allows overriding the mode" do
      flow = Imageflow.new() |> Imageflow.constrain(10, 20, %{mode: "fit"})

      assert %{nodes: %{1 => %{constrain: %{w: 10, h: 20, mode: "fit"}}}} = flow
    end
  end

  describe "region/4" do
    test "appends a region operation" do
      flow = Imageflow.new() |> Imageflow.region(1, 2, 3, 4)

      assert %{
               nodes: %{
                 1 => %{region: %{x1: 1, y1: 2, x2: 3, y2: 4, background_color: "transparent"}}
               }
             } = flow
    end

    test "acepts an optional background color" do
      flow = Imageflow.new() |> Imageflow.region(1, 2, 3, 4, "FF000000")

      assert %{
               nodes: %{
                 1 => %{region: %{x1: 1, y1: 2, x2: 3, y2: 4, background_color: "FF000000"}}
               }
             } = flow
    end
  end

  describe "region_percent/4" do
    test "appends a region_percent operation" do
      flow = Imageflow.new() |> Imageflow.region_percent(1, 2, 3, 4)

      assert %{
               nodes: %{
                 1 => %{
                   region_percent: %{x1: 1, y1: 2, x2: 3, y2: 4, background_color: "transparent"}
                 }
               }
             } = flow
    end

    test "acepts an optional background color" do
      flow = Imageflow.new() |> Imageflow.region_percent(1, 2, 3, 4, "FF000000")

      assert %{
               nodes: %{
                 1 => %{
                   region_percent: %{x1: 1, y1: 2, x2: 3, y2: 4, background_color: "FF000000"}
                 }
               }
             } = flow
    end
  end

  describe "crop_whitespace/3" do
    test "appends a crop_whitespace operation" do
      flow = Imageflow.new() |> Imageflow.crop_whitespace(1, 2)

      assert %{nodes: %{1 => %{crop_whitespace: %{threshold: 1, percent_padding: 2}}}} = flow
    end
  end

  describe "flip_horizontal/1" do
    test "appends a flip_h operation" do
      flow = Imageflow.new() |> Imageflow.flip_horizontal()

      assert %{nodes: %{1 => :flip_h}} = flow
    end
  end

  describe "flip_vertical/1" do
    test "appends a flip_h operation" do
      flow = Imageflow.new() |> Imageflow.flip_vertical()

      assert %{nodes: %{1 => :flip_v}} = flow
    end
  end

  describe "transpose/1" do
    test "appends a flip_h operation" do
      flow = Imageflow.new() |> Imageflow.transpose()

      assert %{nodes: %{1 => :transpose}} = flow
    end
  end

  describe "rotate_90/1" do
    test "appends a flip_h operation" do
      flow = Imageflow.new() |> Imageflow.rotate_90()

      assert %{nodes: %{1 => :rotate_90}} = flow
    end
  end

  describe "rotate_180/1" do
    test "appends a flip_h operation" do
      flow = Imageflow.new() |> Imageflow.rotate_180()

      assert %{nodes: %{1 => :rotate_180}} = flow
    end
  end

  describe "rotate_270/1" do
    test "appends a flip_h operation" do
      flow = Imageflow.new() |> Imageflow.rotate_270()

      assert %{nodes: %{1 => :rotate_270}} = flow
    end
  end

  describe "fill_rect/4" do
    test "appends a fill_rect operation" do
      flow = Imageflow.new() |> Imageflow.fill_rect(1, 2, 3, 4)

      assert %{nodes: %{1 => %{fill_rect: %{x1: 1, y1: 2, x2: 3, y2: 4, color: "black"}}}} = flow
    end

    test "accepts an optional color" do
      flow = Imageflow.new() |> Imageflow.fill_rect(1, 2, 3, 4, "red")

      assert %{nodes: %{1 => %{fill_rect: %{x1: 1, y1: 2, x2: 3, y2: 4, color: "red"}}}} = flow
    end
  end

  describe "expand_canvas/6" do
    test "appends a expand_canvas operation" do
      flow = Imageflow.new() |> Imageflow.expand_canvas(1, 2, 3, 4)

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
             } = flow
    end

    test "accepts an optional color argument" do
      flow = Imageflow.new() |> Imageflow.expand_canvas(1, 2, 3, 4, "FF000000")

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
             } = flow
    end
  end

  describe "transparency/2" do
    test "appends a color_filter_srgb contrast operation" do
      flow = Imageflow.new() |> Imageflow.transparency(10)

      assert %{nodes: %{1 => %{color_filter_srgb: %{alpha: 10}}}} = flow
    end
  end

  describe "contrast/2" do
    test "appends a color_filter_srgb contrast operation" do
      flow = Imageflow.new() |> Imageflow.contrast(10)

      assert %{nodes: %{1 => %{color_filter_srgb: %{contrast: 10}}}} = flow
    end
  end

  describe "brightness/2" do
    test "appends a color_filter_srgb contrast operation" do
      flow = Imageflow.new() |> Imageflow.brightness(10)

      assert %{nodes: %{1 => %{color_filter_srgb: %{brightness: 10}}}} = flow
    end
  end

  describe "saturation/2" do
    test "appends a color_filter_srgb contrast operation" do
      flow = Imageflow.new() |> Imageflow.saturation(10)

      assert %{nodes: %{1 => %{color_filter_srgb: %{saturation: 10}}}} = flow
    end
  end

  describe "color_filter/2" do
    test "appends a generic color_filter_srgb operation" do
      flow = Imageflow.new() |> Imageflow.color_filter(%{alpha: 0})

      assert %{nodes: %{1 => %{color_filter_srgb: %{alpha: 0}}}} = flow
    end
  end
end
