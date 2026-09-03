using System;

public class CircularArray<T>
{
    private  readonly T[] _arr;
    private int _top = 0;
    private int _bottom = 0;
    
    public int Capacity => _arr.Length;
    public int Count { get; private set; } = 0;
    public T Head => this[0];
    
    public CircularArray(int capacity, Func<T> generator = null)
    {
        _arr = new T[capacity];
        if (generator == null) return;
        for (var i = 0; i < _arr.Length; i++)
            _arr[i] = generator();
    }
    
    public T this[int i]
    {
        get
        {
            if(Math.Abs(i) >= Count)
                throw new IndexOutOfRangeException();
            return i > 0 ? 
                _arr[(_bottom + i) % Capacity] : 
                _arr[(_top + i) % Capacity];
        }
    }

    public void Save(T newData, Action<T, T> copyAction)
    {
        if (Count > 0)
        {
            _top++;
            _top %= Capacity;
            if (_bottom == _top)
            {
                _bottom++;
                _bottom %= Capacity;
            }
        }
        copyAction(newData, _arr[_top]);
        if (Count < Capacity)
            Count++;
    }

    public void RemoveTop()
    {
        if (Count == 0) return;
        Count--;
        if (Count == 0) return;
        _top--;
        _top %= Capacity;
    }

    public void Clear()
    {
        _top = 0;
        _bottom = 0;
        Count = 0;
    }
}