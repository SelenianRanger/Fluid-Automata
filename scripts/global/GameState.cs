using System;
using Godot;
using Godot.Collections;

public partial class GameState : Node
{
	[Signal]
	public delegate void TimelineUpdatedEventHandler();
	
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
	
	public CircularBuffer<GridState> Timeline;
	public byte[] Grid => Timeline.Head.Grid;
	public byte[] Neighbors => Timeline.Head.Neighbors;
	public byte[] SectionGrid => Timeline.Head.SectionGrid;
	public byte[] DrawSection = [];
	public Array<Array<Array<Vector2I>>> SectionNeighbors = [];
	public byte[] Brush = new byte[25];
	
	public int CurrentIndex => Timeline.HeadOffset - 1;
	public GridState Current => Timeline[CurrentIndex];
	public int CurrentFrame => CurrentIndex + Timeline.LifetimeCount - Timeline.Count;
	
	public bool IsBufferLoaded = false;
    public bool IsPaused = false;
    public float UpdateSpeed;

    public override void _Ready()
    {
        Instance = this;
    }
    
    public bool AtTimelineHead() => Timeline.HeadOffset == Timeline.Count - 1;

    public void Init()
    {
	    _initSectionNeighbors();
	    Timeline = new CircularBuffer<GridState>(
		    Settings.Instance.Game.UndoCount + 2, 
		    () => new GridState());
	    Timeline.SaveAtHead(GridState.Default, GridState.Copy);
	    System.Array.Resize(ref DrawSection, SectionGrid.Length);
	    System.Array.Fill(DrawSection, (byte)SectionFlag.Draw);
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

    public void OnTimelineUpdated()
    {
	    EmitSignal(SignalName.TimelineUpdated);
    }
    
    public void EditBrush(Vector2I pos, byte value)
    {
	    Brush[GridUtils.GetPackedIndex(new Vector2I(5, 5), pos)] = value;
    }
    
    public void ResetTimeline()
    {
	    Timeline.Clear();
	    Timeline.SaveAtHead(GridState.Default, GridState.Copy);
	    System.Array.Fill(DrawSection, (byte)SectionFlag.Draw);
	    IsBufferLoaded = true;
    }
    
    public void SaveState()
    {
	    Timeline.SaveAtHead(Timeline.Head, GridState.Copy);
	    IsBufferLoaded = false;
    }

    public bool CanUndo() => Timeline.HeadOffset > 1;
    
    public void ResetBuffer()
    {
	    Timeline.RemoveAtHead();
	    SaveState();
	    for (var i = 0; i < SectionGrid.Length; i++)
		    DrawSection[i] = (byte)(SectionGrid[i] & (byte)SectionFlag.Draw);
    }
    
    public void SeekTimeline(int index = -1)
    {
	    if (index == Timeline.HeadOffset || Timeline.IsEmpty()) return;
	    if(index == -1)
	    {
		    SeekTimeline(Timeline.Count - 2);
		    return;
	    }

	    if (index - Timeline.HeadOffset == 1)
	    {
		    Redo();
		    return;
	    }

	    if (index - Timeline.HeadOffset == -2)
	    {
		    Undo();
		    return;
	    }
	    
	    Timeline.SetHead(index);
	    System.Array.Fill(DrawSection, (byte)SectionFlag.Draw);
    }
    
    public void Undo()
    {
	    Timeline.ShiftHead(-1);
	    for (var i = 0; i < SectionGrid.Length; i++)
		    DrawSection[i] = (byte)(SectionGrid[i] & (byte)SectionFlag.Draw);
	    Timeline.ShiftHead(-1);
	    for (var i = 0; i < SectionGrid.Length; i++)
		    DrawSection[i] |= (byte)(SectionGrid[i] & (byte)SectionFlag.Draw);
    }

    public void Redo()
    {
	    Timeline.ShiftHead(1);
	    for (var i = 0; i < SectionGrid.Length; i++)
		    DrawSection[i] = (byte)(SectionGrid[i] & (byte)SectionFlag.Draw);
    }
    
}
