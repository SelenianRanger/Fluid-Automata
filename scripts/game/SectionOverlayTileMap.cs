using Godot;

public partial class SectionOverlayTileMap : TileMapLayer
{
	
	public override void _Ready()
	{
		Scale = Settings.Instance.Game.SectionSize;
	}

	public void OnOverlaysUpdated()
	{
		for (var i = 0; i < Settings.Instance.Game.SectionGridSize.X; i++)
		for (var j = 0; j < Settings.Instance.Game.SectionGridSize.Y; j++)
		{
			var index = GridUtils.GetPackedIndex(
				Settings.Instance.Game.SectionGridSize, 
				new Vector2I(i, j));
			SetCell(new Vector2I(i, j), 0, new Vector2I(GameState.Instance.SectionGrid[index], 0));
		}
	}
}
