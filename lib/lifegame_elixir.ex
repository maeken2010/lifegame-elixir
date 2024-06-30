defmodule Lifegame do
  @moduledoc """
  Documentation for `Lifegame`.
  """

  @doc """
  誕生
  死んでいるセルに隣接する生きたセルがちょうど3つあれば、次の世代が誕生する。
  生存
  生きているセルに隣接する生きたセルが2つか3つならば、次の世代でも生存する。
  過疎
  生きているセルに隣接する生きたセルが1つ以下ならば、過疎により死滅する。
  過密
  生きているセルに隣接する生きたセルが4つ以上ならば、過密により死滅する。
  """
end

defmodule Lifegame.World do
  defstruct board: nil, dead_board: nil, all_empty_board: nil, size: {}

  def init(opts) do
    {size_x, size_y} = Keyword.get(opts, :size, nil) 

    alive_board = Keyword.get(opts, :board, nil) |> MapSet.new()

    all_board =
      Enum.map(0..(size_x-1), fn x ->
        Enum.map(0..(size_y-1), fn y -> {x, y} end)
      end)
      |> List.flatten()
      |> MapSet.new()

    dead_board = MapSet.difference(all_board, alive_board)

    %Lifegame.World{board: alive_board, dead_board: dead_board, all_empty_board: all_board, size: {size_x, size_y}}
  end

  def generation(%Lifegame.World{board: alive_board, dead_board: dead_board} = world) do
    add_next_alive = fn point, acc, target_alived -> 
      is_alive = rule(target_alived, alive_count(alive_board, point))
      case is_alive do
        true -> acc |> MapSet.put(point)
        _ -> acc
      end 
    end

    new_board1 = alive_board |> Enum.reduce(
      MapSet.new(),
      fn point, acc -> add_next_alive.(point, acc, true) end
    )

    new_board2 = dead_board |> Enum.reduce(
      MapSet.new(),
      fn point, acc -> add_next_alive.(point, acc, false) end
    )

    new_board = MapSet.union(new_board1, new_board2)
   
    dead_board = MapSet.difference(world.all_empty_board, new_board)

    %{world | board: new_board, dead_board: dead_board}
  end

  def to_string(world) do
    {size_x, size_y} = world.size
    init_list = 1..size_y |> Enum.map(fn y ->
      Enum.to_list(1..size_x) |> Enum.map(fn _ -> 0 end)
    end)

    world.board
    |> Enum.reduce(init_list, fn {x, y}, acc ->
      old_x_list = Enum.at(acc, y)
      new_x_list = List.replace_at(old_x_list, x, 1)
      List.replace_at(acc, y, new_x_list)
    end)
    |> Enum.map(fn x -> Enum.join(x) end)
    |> Enum.reduce(fn x, acc -> acc <> "\n" <> x end)

  end

  defp neighborhood({x, y}) do
    [
      {x-1, y-1}, {x, y-1}, {x+1, y-1},
      {x-1, y  },           {x+1, y  },
      {x-1, y+1}, {x, y+1}, {x+1, y+1}
    ]
  end

  defp alive_count(board, point) do
    neighborhood(point) |> Enum.filter(fn p -> MapSet.member?(board, p) end) |> Enum.count()
  end

  defp rule(is_alive, alive_count) do
    case is_alive do
      true ->
        cond do
          alive_count < 2 -> false
          alive_count > 3 -> false
          true -> true
        end
      _ ->
        cond do
          alive_count == 3 -> true
          true -> false
        end
    end
  end
end

defmodule Lifegame do
  alias Lifegame.World

  def main() do
    board = [{2, 1}, {3, 2}, {1, 3}, {2, 3}, {3, 3}]
    world = World.init(board: board, size: {10, 10})

    run(world, 0)
  end

  defp run(world, i) when i > 10 do
    IO.puts(World.to_string(world))
  end
  defp run(world, i) do
    IO.puts(World.to_string(world))
    IO.puts("----------")
    run(World.generation(world), i+1)
  end
end

