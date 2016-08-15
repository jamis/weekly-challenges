defmodule Grid do
  defstruct cells: MapSet.new, start_pos: {0,0}, end_pos: {0,0}

  def from_file(filename) do
    lines = File.stream!(filename, [ :read, :utf8 ], :line)
          |> Enum.reduce([], fn line, list -> [ String.to_char_list(line) | list ] end)
          |> Enum.reverse

    build_grid %Grid{}, 0, lines
  end

  def find_path(grid) do
    ant_step(
      grid,
      [ grid.start_pos ],
      MapSet.new,
      0,
      %{}
    )
  end

  defp build_grid(grid, _, []) do
    grid
  end

  defp build_grid(grid, row, [ line | lines ]) do
    build_grid(
      parse_line(grid, row, 0, line),
      row+1, lines)
  end

  defp parse_line(grid, _, _, []) do
    grid
  end

  defp parse_line(grid, row, col, [ char | chars ]) do
    parse_line process_char(grid, row, col, char), row, col+1, chars
  end

  defp process_char(grid, row, col, char) do
    case char do
      ?# -> grid
      _ ->
        pos = { row, col }
        temp = %{grid | cells: MapSet.put(grid.cells, pos)}

        case char do
          ?O -> %{temp | start_pos: pos}
          ?X -> %{temp | end_pos: pos}
          _ -> temp
        end
    end
  end

  defp ant_step(grid, [], frontier, _, distances) when frontier == %MapSet{} do
    trace_path(grid.end_pos, grid.start_pos, distances, [])
  end

  defp ant_step(grid, [], frontier, distance, distances) do
    # current ants are exhausted, repeat with the frontier set
    ant_step(grid, MapSet.to_list(frontier), MapSet.new, distance+1, distances)
  end

  defp ant_step(grid, [ant | ants], frontier, distance, distances) do
    { frontier, distances } = case Map.has_key?(distances, ant) do
      true -> { frontier, distances }
      false ->
        { frontier_for(ant, grid, distances, frontier),
          Map.put(distances, ant, distance) }
    end

    ant_step(grid, ants, frontier, distance, distances)
  end

  defp frontier_for({row,col}, grid, distances, list) do
    list = check_frontier({row-1,col}, grid, distances, list)
    list = check_frontier({row+1,col}, grid, distances, list)
    list = check_frontier({row,col+1}, grid, distances, list)
    check_frontier({row,col-1}, grid, distances, list)
  end

  defp check_frontier(pos, grid, distances, list) do
    case MapSet.member?(grid.cells, pos) && !Map.has_key?(distances, pos) do
      true -> MapSet.put(list, pos)
      false -> list
    end
  end

  defp trace_path(current, initial, _, path) when current == initial do
    [ initial | path ]
  end

  defp trace_path(current, initial, distances, path) do
    { row, col } = current
    distance = Map.get(distances, current)

    neighbor = [ {row-1, col}, {row+1, col}, {row, col-1}, {row, col+1} ]
             |> Enum.find(fn n -> Map.get(distances, n) == distance-1 end)

    trace_path neighbor, initial, distances, [ current | path ]
  end

end

grid = Grid.from_file "input/maze-normal-010.txt"
path = Grid.find_path(grid)

%{ dirs: directions } = Enum.reduce(tl(path), %{ prev: hd(path), dirs: [] },
      fn(cell, acc) ->
        %{ prev: prev, dirs: dirs } = acc

        { row, col } = cell
        { prow, pcol } = prev

        dir = cond do
          row - prow < 0 -> "north"
          row - prow > 0 -> "south"
          col - pcol < 0 -> "west"
          col - pcol > 0 -> "east"
        end

        %{ prev: cell, dirs: [ dir | dirs ] }
      end)

IO.puts(directions |> Enum.reverse |> Enum.join("\n"))
IO.puts "#{length(directions)} steps"
