using System.Collections.Generic;
using Godot;

public static class GameRules
{
    public delegate bool GameRule(Vector2I pos);

    private static bool Overpopulation(Vector2I pos)
    {
        var index = GridUtils.GetPackedIndex(Settings.Instance.Game.GridSize, pos);
        if (GameState.Instance.Grid[index] == 0) return false;
        if (GameState.Instance.Neighbors[index] > 3)
        {
            GameState.Instance.Grid[index] = 0;
            return true;
        }
        return false;
    }
    
    private static bool Underpopulation(Vector2I pos)
    {
        var index = GridUtils.GetPackedIndex(Settings.Instance.Game.GridSize, pos);
        if (GameState.Instance.Grid[index] == 0) return false;
        if (GameState.Instance.Neighbors[index] < 2)
        {
            GameState.Instance.Grid[index] = 0;
            return true;
        }
        return false;
    }

    private static bool Repopulation(Vector2I pos)
    {
        var index = GridUtils.GetPackedIndex(Settings.Instance.Game.GridSize, pos);
        if (GameState.Instance.Grid[index] == 1) return false;
        if (GameState.Instance.Neighbors[index] == 3)
        {
            GameState.Instance.Grid[index] = 1;
            return true;
        }
        return false;
    }

    public static readonly List<GameRule> Rules =
    [
        Overpopulation,
        Underpopulation,
        Repopulation
    ];

}
