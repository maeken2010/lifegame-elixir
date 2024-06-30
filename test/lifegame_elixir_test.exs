"""
- worldが標準出力で見れる
- worldがguiで見れる
- worldを初期化できる
- generationを１つ次にできる
- generationを１秒ごとに自動で動かせる
- generationを止めることが出来る
- cellの生死を切り替えできる
- generationの世代数がわかる
- 初期値がランダム
- 並列処理される
- cellオートマトンのルールを追加できる
"""

defmodule LifegameTest do
  use ExUnit.Case
  doctest Lifegame

  test "worldを初期化出来る" do
    %{ board: board } = Lifegame.World.init(board: [{ 0, 0 }], size: {1, 1})
    assert MapSet.to_list(board) == [{0, 0}] 
  end

  test "generationを１つ次にできる" do
    %{ board: board } = Lifegame.World.init(board: [], size: {0, 0}) |> Lifegame.World.generation()
    assert MapSet.to_list(board) == []
  end

  test "過疎のテスト" do
    %{ board: board } = Lifegame.World.init(board: [{0, 0}], size: {3, 3}) |> Lifegame.World.generation()
    assert MapSet.to_list(board) == []

    %{ board: board } = Lifegame.World.init(board: [{0, 0}, {1, 1}], size: {3, 3}) |> Lifegame.World.generation()
    assert MapSet.member?(board, {1, 1}) == false
  end

  test "過密のテスト" do
    %{ board: board } = Lifegame.World.init(board: [{0, 0}, {0, 1}, {0, 2}, {1, 1}, {2, 2}], size: {3, 3}) |> Lifegame.World.generation()
    assert MapSet.member?(board, {1, 1}) == false
  end

  test "生存のテスト" do
    %{ board: board } = Lifegame.World.init(board: [{0, 0}, {0, 1}, {1, 1}, {2, 2}], size: {3, 3}) |> Lifegame.World.generation()
    assert MapSet.member?(board, {1, 1}) == true

    %{ board: board } = Lifegame.World.init(board: [{0, 0}, {1, 1}, {2, 2}], size: {3, 3}) |> Lifegame.World.generation()
    assert MapSet.member?(board, {1, 1}) == true
  end

  test "誕生のテスト" do
    %{ board: board } = Lifegame.World.init(board: [{0, 0}, {0, 1}, {2, 2}], size: {3, 3}) |> Lifegame.World.generation()
    assert MapSet.member?(board, {1, 1}) == true
  end

  test "std outputにworldを出力できる" do
    world = Lifegame.World.init(board: [{0, 0}, {1, 0}, {2, 2}], size: {3, 4})
    world_string = Lifegame.World.to_string(world)
    assert world_string == "110\n000\n001\n000"


    board = [{1, 0}, {2, 1}, {0, 2}, {1, 2}, {2, 2}]
    world = Lifegame.World.init(board: board, size: {3, 3})
    world_string = Lifegame.World.to_string(world)
    assert world_string == "010\n001\n111"
  end

  test "グライダーのテスト" do
    board = [{1, 0}, {2, 1}, {0, 2}, {1, 2}, {2, 2}]
    world = Lifegame.World.init(board: board, size: {10, 10})
    assert MapSet.equal?(world.board, MapSet.new([{1, 0}, {2, 1}, {0, 2}, {1, 2}, {2, 2}])) 

    world = Lifegame.World.generation(world)
    assert MapSet.equal?(world.board, MapSet.new([{0, 1}, {2, 1}, {1, 2}, {2, 2}, {1, 3}])) 

    world = Lifegame.World.generation(world)
    assert MapSet.equal?(world.board, MapSet.new([{2, 1}, {0, 2}, {2, 2}, {1, 3}, {2, 3}])) 
  end
end
