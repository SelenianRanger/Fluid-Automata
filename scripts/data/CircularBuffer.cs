using System;
using Godot;

public partial class CircularBuffer<T> : RefCounted
{
    private  readonly T[] _arr;
    private int _top = 0;
    private int _bottom = 0;
    private int _bottomCount = 0;

    public int Capacity => _arr.Length;
    public int Count { get; private set; } = 0;
    public int LifetimeCount=> _bottomCount + Count;
    public int HeadOffset { get; private set; } = 0;
    public T Head => this[0];

    public CircularBuffer(int capacity, Func<T> generator = null)
    {
        _arr = new T[capacity];
        if (generator == null) return;
        for (var i = 0; i < _arr.Length; i++)
            _arr[i] = generator();
    }

    public T this[int i] => Count == 0 ?
        throw new IndexOutOfRangeException("Buffer is empty.") :
        _arr[(_bottom + (HeadOffset + i) % Count) % Capacity];
    
    public bool IsEmpty() => Count == 0;

    public void ShiftHead(int offset)
    {
        SetHead((HeadOffset + offset) % Count);
    }
    
    public void SetHead(int newIndex)
    {
        if(Count == 0) throw new IndexOutOfRangeException("Buffer is empty.");
        if(newIndex < 0 || newIndex >= Count) throw new IndexOutOfRangeException("Index is out of range.");
        HeadOffset = newIndex;
    }

    public void SaveAtHead(T newData, Action<T, T> copyAction)
    {
        if (Count > 0)
        {
            HeadOffset++;
            _top = (_bottom + HeadOffset) % Capacity;
            if (_bottom == _top)
            {
                HeadOffset--;
                _bottom++;
                _bottom %= Capacity;
                _bottomCount++;
            }
        }
        copyAction(newData, _arr[_top]);
        Count = HeadOffset + 1;
    }

    public void RemoveAtHead()
    {
        if (Count == 0) throw new IndexOutOfRangeException("Buffer is empty.");
        if (Count == 1)
        {
            Count = 0;
            return;
        }
        if (HeadOffset == 0)
        {
            _top = _bottom;
            Count = 0;
            return;
        }

        HeadOffset--;
        _top = (_bottom + HeadOffset) % Capacity;
        Count = HeadOffset + 1;
    }

    public void Clear()
    {
        _top = 0;
        _bottom = 0;
        _bottomCount = 0;
        HeadOffset = 0;
        Count = 0;
    }
}