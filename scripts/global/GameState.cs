using System;
using Godot;
using Godot.Collections;

public partial class GameState : Node
{
	public static GameState Instance { get; private set; }

	[Flags]
	public enum SectionFlag : byte
	{
		Pass = 0,
		Draw = 1 << 0,
		Process = 1 << 1
	}

	public readonly int PASS = (int)SectionFlag.Pass;
	public readonly int DRAW = (int)SectionFlag.Draw;
	public readonly int PROCESS = (int)SectionFlag.Process;

	public partial class GridState : RefCounted
	{
		public byte[] Grid { get; } =
			new byte[Settings.Instance.Game.GridSize.X * Settings.Instance.Game.GridSize.Y];

		public byte[] Neighbors { get; } =
			new byte[Settings.Instance.Game.GridSize.X * Settings.Instance.Game.GridSize.Y];

		public byte[] SectionGrid { get; } =
			new byte[Settings.Instance.Game.SectionGridSize.X * Settings.Instance.Game.SectionGridSize.Y];

		public static void Copy(GridState from, GridState to)
		{
			from.Grid.AsSpan().CopyTo(to.Grid);
			from.Neighbors.AsSpan().CopyTo(to.Neighbors);
			from.SectionGrid.AsSpan().CopyTo(to.SectionGrid);
		}
		
		public static GridState Default
		{
			get
			{
				var state = new GridState();
				
				System.Array.Fill(state.Grid, (byte)0);
				System.Array.Fill(state.Neighbors, (byte)0);
				System.Array.Fill(state.SectionGrid, (byte)SectionFlag.Draw);

				return state;
			}
		}
	}
	
	public CircularArray<GridState> StateBuffer;
	public byte[] Grid => StateBuffer.Head.Grid;
	public byte[] Neighbors => StateBuffer.Head.Neighbors;
	public byte[] SectionGrid => StateBuffer.Head.SectionGrid;
	
	public bool IsBufferLoaded;
	
	public byte[] Brush = new byte[25];
    public Array<Array<Array<Vector2I>>> SectionNeighbors = [];

    public GridState Current => IsBufferLoaded ? StateBuffer[-1] : StateBuffer.Head;

    public bool IsPaused = false;
    public float UpdateSpeed;

    public override void _Ready()
    {
        Instance = this;
    }

    public void Init()
    {
	    _initSectionNeighbors();
	    StateBuffer = new CircularArray<GridState>(
		    Settings.Instance.Game.UndoCount + 2, 
		    () => new GridState());
	    StateBuffer.Save(GridState.Default, GridState.Copy);
	    IsBufferLoaded = true;
    }

    private void _initSectionNeighbors()
    {
	    SectionNeighbors.Resize(Settings.Instance.Game.GridSize.X);
	    for (var i = 0; i < Settings.Instance.Game.GridSize.X; i++)
	    {
		    SectionNeighbors[i] = [];
		    SectionNeighbors[i].Resize(Settings.Instance.Game.GridSize.Y);
		    var subI = i / Settings.Instance.Game.SectionSize.X;
		    for (var j = 0; j < Settings.Instance.Game.GridSize.Y; j++)
		    {
			    SectionNeighbors[i][j] = [];
			    var subJ =  j / Settings.Instance.Game.SectionSize.Y;
			    if (subI > 0 && i == subI * Settings.Instance.Game.SectionSize.X)
			    {
				    SectionNeighbors[i][j].Add(new Vector2I(subI - 1, subJ));
				    if (subJ > 0 && j == subJ * Settings.Instance.Game.SectionSize.Y)
					    SectionNeighbors[i][j].Add(new Vector2I(subI - 1, subJ - 1));
				    else if (subJ < Settings.Instance.Game.SectionGridSize.Y - 1 && 
				             j == (subJ + 1) * Settings.Instance.Game.SectionSize.Y - 1)
					    SectionNeighbors[i][j].Add(new Vector2I(subI - 1, subJ + 1));
			    }
			    else if (subI < Settings.Instance.Game.SectionGridSize.X - 1 && 
			             i == (subI + 1) * Settings.Instance.Game.SectionSize.X - 1)
			    {
				    SectionNeighbors[i][j].Add(new Vector2I(subI + 1, subJ));
				    if (subJ > 0 && j == subJ * Settings.Instance.Game.SectionSize.Y)
					    SectionNeighbors[i][j].Add(new Vector2I(subI + 1, subJ - 1));
				    else if (subJ < Settings.Instance.Game.SectionGridSize.Y - 1 && 
				             j == (subJ + 1) * Settings.Instance.Game.SectionSize.Y - 1)
					    SectionNeighbors[i][j].Add(new Vector2I(subI + 1, subJ + 1));
			    }

			    if (subJ > 0 && j == subJ * Settings.Instance.Game.SectionSize.Y)
				    SectionNeighbors[i][j].Add(new Vector2I(subI, subJ - 1));
			    else if (subJ < Settings.Instance.Game.SectionGridSize.Y - 1 && 
			             j == (subJ + 1) * Settings.Instance.Game.SectionSize.Y - 1)
				    SectionNeighbors[i][j].Add(new Vector2I(subI, subJ + 1));
		    }
	    }
    }

    public void EditBrush(Vector2I pos, byte value)
    {
	    Brush[GridUtils.GetPackedIndex(new Vector2I(5, 5), pos)] = value;
    }
    
    public void ClearStateBuffer()
    {
	    StateBuffer.Clear();
	    StateBuffer.Save(GridState.Default, GridState.Copy);
	    IsBufferLoaded = true;
    }
    
    public void SaveState()
    {
	    StateBuffer.Save(StateBuffer.Head, GridState.Copy);
    }

    public bool CanUndo()
    {
	    return StateBuffer.Count > 2 + (IsBufferLoaded ? 1 : 0);
    }
    
    public void DiscardBuffer()
    {
	    StateBuffer.RemoveTop();
	    IsBufferLoaded = false;
    }
    
    public void Undo()
    {
	    if (!CanUndo()) return;
	    DiscardBuffer();
	    
	    var oldSectionGrid = SectionGrid;
	    StateBuffer.RemoveTop();
	    for (var i = 0; i < SectionGrid.Length; i++)
		    SectionGrid[i] |= (byte)(oldSectionGrid[i] & (byte)SectionFlag.Draw);
	    IsBufferLoaded = true;
    }
    
}
