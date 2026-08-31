using System;
using Godot;
using Godot.Collections;

public partial class GameState : Node
{
	public enum Data
	{
		Brush, Grid, Neighbors, SectionGrid
	}

	public readonly int BRUSH = (int)Data.Brush;
	public readonly int GRID = (int)Data.Grid;
	public readonly int NEIGHBORS = (int)Data.Neighbors;
	public readonly int SECTIONGRID = (int)Data.SectionGrid;
	
	public static GameState Instance { get; private set; }
	public byte[] Brush = new byte[25];
	public byte[] Grid = [];
	public byte[] Neighbors = [];
	public byte[] SectionGrid = [];
    public Array<Array<Array<Vector2I>>> SectionNeighbors = [];
    
    public bool IsPaused = false;
    public float UpdateSpeed;

    public override void _Ready()
    {
        Instance = this;
    }

    public void SetDataCell(Data data, Vector2I pos,  byte value)
    {
	    switch (data)
	    {
		    case Data.Brush:
			    Brush[GridUtils.GetPackedIndex(new Vector2I(5, 5), pos)] = value;
			    break;
		    case Data.Grid:
			    Grid[GridUtils.GetPackedIndex(Settings.Instance.Game.GridSize, pos)] = value;
			    break;
		    case Data.Neighbors:
			    Neighbors[GridUtils.GetPackedIndex(Settings.Instance.Game.GridSize, pos)] = value;
			    break;
		    case Data.SectionGrid:
			    SectionGrid[GridUtils.GetPackedIndex(Settings.Instance.Game.SectionGridSize, pos)] = value;
			    break;
	    }
    }
}
