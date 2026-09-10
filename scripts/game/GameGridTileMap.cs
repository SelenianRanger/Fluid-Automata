using Godot;
using System;

public partial class GameGridTileMap : TileMapLayer
{

	public void OnGridUpdated()
	{
		for (var subI = 0; subI < Settings.Instance.Game.SectionGridSize.X; subI++)
		for (var subJ = 0; subJ < Settings.Instance.Game.SectionGridSize.Y; subJ++)
		{
			var index = GridUtils.GetPackedIndex(
				Settings.Instance.Game.SectionGridSize, 
				new Vector2I(subI, subJ));
			if ((GameState.Instance.DrawSection[index] & (byte)GameState.SectionFlag.Draw) == 0) continue;
			var i1 = Math.Max(1, subI * Settings.Instance.Game.SectionSize.X);
			var i2 = Math.Min(Settings.Instance.Game.GridSize.X - 1, i1 + Settings.Instance.Game.SectionSize.X);
			var j1 = Math.Max(1, subJ * Settings.Instance.Game.SectionSize.Y);
			var j2 = Math.Min(Settings.Instance.Game.GridSize.Y - 1, j1 + Settings.Instance.Game.SectionSize.Y);
			for (var i = i1; i < i2; i++)
			for (var j = j1; j < j2; j++)
			{
				index = GridUtils.GetPackedIndex(
					Settings.Instance.Game.GridSize, 
					new Vector2I(i, j));
				SetCell(new Vector2I(i - 1, j - 1), 0, new Vector2I(GameState.Instance.Grid[index], 0));
			}
		}
	}
}
