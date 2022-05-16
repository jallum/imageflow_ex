defmodule Imageflow.Runner do
  alias Imageflow.{Native}

  def run(%Imageflow{} = graph, opts \\ []) do
    name = "v0.1/execute"

    with {:ok, job} <- Native.create() do
      result =
        with :ok <- add_inputs(job, graph.inputs, opts),
             :ok <- add_outputs(job, graph.outputs),
             {:ok, _} <- Native.message(job, name, graph) do
          save_outputs(job, graph.outputs, opts)
        end

      :ok = Native.destroy(job)

      result
    end
  end

  defp add_inputs(job, inputs, opts) do
    inputs
    |> Enum.reduce(:ok, fn
      {id, value}, :ok ->
        case value do
          {:binary, atom} when is_atom(atom) ->
            binary = opts[atom] || raise "expected a binary named #{inspect(atom)}"
            Native.add_input_buffer(job, id, binary)

          {:binary, binary} ->
            Native.add_input_buffer(job, id, binary)

          {:file, atom} when is_atom(atom) ->
            path = opts[atom] || raise "expected a file path named #{inspect(atom)}"
            Native.add_input_file(job, id, path)

          {:file, path} ->
            Native.add_input_file(job, id, path)
        end

      _, {:error, _reason} = error ->
        error
    end)
  end

  defp add_outputs(job, outputs) do
    outputs
    |> Enum.reduce(:ok, fn
      {id, _}, :ok ->
        Native.add_output_buffer(job, id)

      _, {:error, _reason} = error ->
        error
    end)
  end

  defp save_outputs(job, outputs, opts) do
    outputs
    |> Enum.reduce({:ok, %{}}, fn
      {id, value}, {:ok, %{} = outputs} = state ->
        case value do
          {:file, atom} when is_atom(atom) ->
            path = opts[atom] || raise "expected an output file path named #{inspect(atom)}"
            {:ok, outputs |> Map.put(atom, Native.save_output_to_file(job, id, path))}

          {:file, path} ->
            {:ok, outputs |> Map.put(path, Native.save_output_to_file(job, id, path))}

          {:binary, atom} when is_atom(atom) ->
            with {:ok, buffer} <- Native.get_output_buffer(job, id) do
              {:ok, outputs |> Map.put(atom, buffer)}
            end

          _ ->
            state
        end

      _, {:error, _reason} = error ->
        error
    end)
  end
end
