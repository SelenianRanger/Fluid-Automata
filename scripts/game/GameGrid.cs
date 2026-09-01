using Godot;
using System;

public partial class GameGrid : Node
{
	[Signal]
	public delegate void GridUpdatedEventHandler();
	
	public override void _Ready()
	{
		var timer = GetNode<Timer>("Timer");
		Init();
		UpdateTick();
		timer.Timeout += UpdateTick;
		timer.WaitTime = 1f / Settings.Instance.Game.UpdateSpeed;
		timer.Start();
	}
	
	private void Init()
	{
		Array.Resize(ref GameState.Instance.Grid, 
			Settings.Instance.Game.GridSize.X * Settings.Instance.Game.GridSize.Y);
		Array.Resize(ref GameState.Instance.Neighbors, 
			Settings.Instance.Game.GridSize.X * Settings.Instance.Game.GridSize.Y);
		Array.Resize(ref GameState.Instance.SectionGrid, 
			Settings.Instance.Game.SectionGridSize.X * Settings.Instance.Game.SectionGridSize.Y);
		Array.Fill(GameState.Instance.Grid, (byte)0);
		Array.Fill(GameState.Instance.Neighbors, (byte)0);
		Array.Fill(GameState.Instance.SectionGrid, (byte)1);

		GameState.Instance.SectionNeighbors.Resize(Settings.Instance.Game.GridSize.X);
		for (var i = 0; i < Settings.Instance.Game.GridSize.X; i++)
		{
			GameState.Instance.SectionNeighbors[i] = [];
			GameState.Instance.SectionNeighbors[i].Resize(Settings.Instance.Game.GridSize.Y);
			var subI = i / Settings.Instance.Game.SectionSize.X;
			for (var j = 0; j < Settings.Instance.Game.GridSize.Y; j++)
			{
				GameState.Instance.SectionNeighbors[i][j] = [];
				var subJ =  j / Settings.Instance.Game.SectionSize.Y;
				if (subI > 0 && i == subI * Settings.Instance.Game.SectionSize.X)
				{
					GameState.Instance.SectionNeighbors[i][j].Add(new Vector2I(subI - 1, subJ));
					if (subJ > 0 && j == subJ * Settings.Instance.Game.SectionSize.Y)
						GameState.Instance.SectionNeighbors[i][j].Add(new Vector2I(subI - 1, subJ - 1));
					else if (subJ < Settings.Instance.Game.SectionGridSize.Y - 1 && 
					         j == (subJ + 1) * Settings.Instance.Game.SectionSize.Y - 1)
						GameState.Instance.SectionNeighbors[i][j].Add(new Vector2I(subI - 1, subJ + 1));
				}
				else if (subI < Settings.Instance.Game.SectionGridSize.X - 1 && 
				         i == (subI + 1) * Settings.Instance.Game.SectionSize.X - 1)
				{
					GameState.Instance.SectionNeighbors[i][j].Add(new Vector2I(subI + 1, subJ));
					if (subJ > 0 && j == subJ * Settings.Instance.Game.SectionSize.Y)
						GameState.Instance.SectionNeighbors[i][j].Add(new Vector2I(subI + 1, subJ - 1));
					else if (subJ < Settings.Instance.Game.SectionGridSize.Y - 1 && 
					         j == (subJ + 1) * Settings.Instance.Game.SectionSize.Y - 1)
						GameState.Instance.SectionNeighbors[i][j].Add(new Vector2I(subI + 1, subJ + 1));
				}

				if (subJ > 0 && j == subJ * Settings.Instance.Game.SectionSize.Y)
					GameState.Instance.SectionNeighbors[i][j].Add(new Vector2I(subI, subJ - 1));
				else if (subJ < Settings.Instance.Game.SectionGridSize.Y - 1 && 
				         j == (subJ + 1) * Settings.Instance.Game.SectionSize.Y - 1)
					GameState.Instance.SectionNeighbors[i][j].Add(new Vector2I(subI, subJ + 1));
			}
		}
	}

	public void ResetGrid()
	{
		Array.Fill(GameState.Instance.Grid, (byte)0);
		Array.Fill(GameState.Instance.SectionGrid, (byte)1);
		GameState.Instance.ResetUndo();
		GameState.Instance.TickState = GameState.TickStatus.DrawOnly;
		UpdateTick();
	}
	
	public void ResetGrid(byte[] fill)
	{
		fill.AsSpan().CopyTo(GameState.Instance.Grid);
		Array.Fill(GameState.Instance.SectionGrid, (byte)1);
		GameState.Instance.ResetUndo();
		GameState.Instance.TickState = GameState.TickStatus.FullTick;
		UpdateTick();
	}

	private int UpdateTile(Vector2I pos)
	{
		foreach (var rule in GameRules.Rules)
			if (rule(pos))
			{
				MarkSection(pos);
				return 1;
			}
		return 0;
	}

	public void SetTile(Vector2I pos, byte value)
	{
		var index = GridUtils.GetPackedIndex(Settings.Instance.Game.GridSize, pos);
		if (GameState.Instance.Grid[index] == value) return;
		GameState.Instance.Grid[index] = value;
		MarkSection(pos);
		GameState.Instance.TickState = GameState.TickStatus.FullTick;
	}
	
	public void MarkSection(Vector2I pos)
	{
		var subI = pos.X /  Settings.Instance.Game.SectionSize.Y;
		var subJ = pos.Y /  Settings.Instance.Game.SectionSize.Y;
		GameState.Instance.SectionGrid[GridUtils.GetPackedIndex(
			Settings.Instance.Game.SectionGridSize, 
			new Vector2I(subI, subJ))] = 1;
		
		foreach (var neighbor in GameState.Instance.SectionNeighbors[pos.X][pos.Y])
		{
			var index = GridUtils.GetPackedIndex(
				Settings.Instance.Game.SectionGridSize, 
				new Vector2I(neighbor.X, neighbor.Y));
			if (GameState.Instance.SectionGrid[index] != 1)
				GameState.Instance.SectionGrid[index] = 2;
		}
	}

	private void UpdateSectionNeighbors(int id)
	{
		var subI = id /  Settings.Instance.Game.SectionGridSize.Y;
		var subJ = id %  Settings.Instance.Game.SectionGridSize.Y;
		var index = GridUtils.GetPackedIndex(
			Settings.Instance.Game.SectionGridSize, 
			new Vector2I(subI, subJ));
		if (GameState.Instance.SectionGrid[index] != 1) return;
		var i1 = Math.Max(1, subI * Settings.Instance.Game.SectionSize.X);
		var i2 = Math.Min(Settings.Instance.Game.GridSize.X - 1, i1 + Settings.Instance.Game.SectionSize.X);
		var j1 = Math.Max(1, subJ * Settings.Instance.Game.SectionSize.Y);
		var j2 = Math.Min(Settings.Instance.Game.GridSize.Y - 1, j1 + Settings.Instance.Game.SectionSize.Y);
		
		for (var x = i1; x < i2; x++)
		for (var y = j1; y < j2; y++)
		{
			index = GridUtils.GetPackedIndex(Settings.Instance.Game.GridSize, 
				new Vector2I(x, y));
			GameState.Instance.Neighbors[index] = 0;
			for (var i = -1; i < 2; i++)
			for (var j = -1; j < 2; j++)
			{
				if (i == 0 && j == 0) continue;
				var index2 = GridUtils.GetPackedIndex(Settings.Instance.Game.GridSize, 
					new Vector2I(x + i, y + j));
				GameState.Instance.Neighbors[index] += GameState.Instance.Grid[index2];
			}
		}
	}

	private void UpdateSection(int id)
	{
		var subI = id /  Settings.Instance.Game.SectionGridSize.Y;
		var subJ = id %  Settings.Instance.Game.SectionGridSize.Y;
		var index = GridUtils.GetPackedIndex(Settings.Instance.Game.SectionGridSize, 
			new Vector2I(subI, subJ));
		if (GameState.Instance.SectionGrid[index] != 1) return;
		var tilesChanged = 0;
		var i1 = Math.Max(1, subI * Settings.Instance.Game.SectionSize.X);
		var i2 = Math.Min(Settings.Instance.Game.GridSize.X - 1, i1 + Settings.Instance.Game.SectionSize.X);
		var j1 = Math.Max(1, subJ * Settings.Instance.Game.SectionSize.Y);
		var j2 = Math.Min(Settings.Instance.Game.GridSize.Y - 1, j1 + Settings.Instance.Game.SectionSize.Y);
		
		for (var i = i1; i < i2; i++)
		for (var j = j1; j < j2; j++)
			tilesChanged += UpdateTile(new Vector2I(i, j));
		if (tilesChanged == 0)
			GameState.Instance.SectionGrid[index] = 0;
		else
			GameState.Instance.TickState = GameState.TickStatus.FullTick;
	}

	public void UpdateNeighbors()
	{
		var taskId = WorkerThreadPool.AddGroupTask(Callable.From<int>(UpdateSectionNeighbors), 
			Settings.Instance.Game.SectionGridSize.X * Settings.Instance.Game.SectionGridSize.Y);
		WorkerThreadPool.WaitForGroupTaskCompletion(taskId);
	}

	public void UpdateGrid()
	{
		var taskId = WorkerThreadPool.AddGroupTask(Callable.From<int>(UpdateSection), 
			Settings.Instance.Game.SectionGridSize.X * Settings.Instance.Game.SectionGridSize.Y);
		WorkerThreadPool.WaitForGroupTaskCompletion(taskId);
	}

	public void Undo()
	{
		GameState.Instance.Undo();
		UpdateTick();
	}
	
	public void RevertBuffer()
	{
		GameState.Instance.RevertToSnapshot();
	}
	
	public void BufferNextFrame()
	{
		GameState.Instance.TickState = GameState.TickStatus.DrawOnly;
		UpdateNeighbors();
		UpdateGrid();
	}
	
	public void UpdateTick()
	{
		if (GameState.Instance.TickState == GameState.TickStatus.Idle) return;
		GameState.Instance.PushUndo();
		EmitSignal(SignalName.GridUpdated);
		if(GameState.Instance.TickState == GameState.TickStatus.DrawOnly)
		{
			GameState.Instance.TickState = GameState.TickStatus.Idle;
			return;
		}
		
		BufferNextFrame();
	}
	
}
