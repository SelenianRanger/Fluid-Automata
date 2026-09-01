using System.Collections.Generic;
using Godot;
using Godot.Collections;

public partial class GameState : Node
{
	public static GameState Instance { get; private set; }
	
	public enum DataType
	{
		Brush, Grid, Neighbors, SectionGrid
	}
	
	public readonly int BRUSH = (int)DataType.Brush;
	public readonly int GRID = (int)DataType.Grid;
	public readonly int NEIGHBORS = (int)DataType.Neighbors;
	public readonly int SECTIONGRID = (int)DataType.SectionGrid;
	
	public enum TickStatus
	{
		Idle, DrawOnly, FullTick
	}

	public partial class GridState(byte[] grid, byte[] neighbors, byte[] sectionGrid, TickStatus tickStatus) : RefCounted
	{
		public byte[] Grid { get; } = (byte[])grid.Clone();
		public byte[] Neighbors { get; } = (byte[])neighbors.Clone();
		public byte[] SectionGrid { get; } = (byte[])sectionGrid.Clone();
		public TickStatus TickState = tickStatus;
	}
	
	public byte[] Brush = new byte[25];
	public byte[] Grid = [];
	public byte[] Neighbors = [];
	public byte[] SectionGrid = [];
	public TickStatus TickState = TickStatus.DrawOnly;
	
    public Array<Array<Array<Vector2I>>> SectionNeighbors = [];
    
    public LinkedList<GridState> UndoStack = new();
    public GridState Snapshot => UndoStack.First?.Value;
    
    public bool IsPaused = false;
    public float UpdateSpeed;

    public override void _Ready()
    {
        Instance = this;
    }

    public void SetDataCell(DataType data, Vector2I pos,  byte value)
    {
	    switch (data)
	    {
		    case DataType.Brush:
			    Brush[GridUtils.GetPackedIndex(new Vector2I(5, 5), pos)] = value;
			    break;
		    case DataType.Grid:
			    Grid[GridUtils.GetPackedIndex(Settings.Instance.Game.GridSize, pos)] = value;
			    break;
		    case DataType.Neighbors:
			    Neighbors[GridUtils.GetPackedIndex(Settings.Instance.Game.GridSize, pos)] = value;
			    break;
		    case DataType.SectionGrid:
			    SectionGrid[GridUtils.GetPackedIndex(Settings.Instance.Game.SectionGridSize, pos)] = value;
			    break;
	    }
    }
    
    public bool CanUndo()
    {
	    return UndoStack.Count > 1;
    }
    
    public void ResetUndo()
    {
	    UndoStack.Clear();
    }
    
    public void PushUndo()
    {
	    if (UndoStack.Count >= Settings.Instance.Game.UndoCount)
		    UndoStack.RemoveLast();
	    UndoStack.AddFirst(new GridState(Grid, Neighbors, SectionGrid, TickState));
    }

    public void Undo()
    {
	    if (!CanUndo()) return;
	    UndoStack.RemoveFirst();
	    PopUndo();
    }

    public void PopUndo()
    {
	    if (UndoStack.Count < 1) return;
	    var snapshot = UndoStack.First!.Value;
	    TickState = snapshot.TickState;
	    Grid = (byte[])snapshot.Grid.Clone();
	    Neighbors = (byte[])snapshot.Neighbors.Clone();
	    
	    var oldSectionGrid = (byte[])SectionGrid.Clone();
	    SectionGrid = (byte[])snapshot.SectionGrid.Clone();
	    for (var i = 0; i < SectionGrid.Length; i++)
		    if((oldSectionGrid[i] & 1) == 1 && SectionGrid[i] != oldSectionGrid[i])
				SectionGrid[i] += 1;
	    UndoStack.RemoveFirst();
    }

    public void RevertToSnapshot()
    {
	    if (UndoStack.Count < 1) return;
	    var snapshot = UndoStack.First!.Value;
	    TickState = snapshot.TickState;
	    Grid = (byte[])snapshot.Grid.Clone();
	    Neighbors = (byte[])snapshot.Neighbors.Clone();
	    SectionGrid = (byte[])snapshot.SectionGrid.Clone();
    }
}
