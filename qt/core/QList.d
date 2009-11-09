module qt.core.QList;

import qt.QGlobal;
import qt.qtd.Atomic;

import core.stdc.stdlib : qRealloc = realloc, qFree = free, qMalloc = malloc;
import core.stdc.string : memcpy, memmove;

enum INT_MAX = int.max;

int qAllocMore(int alloc, int extra)
{
    if (alloc == 0 && extra == 0)
        return 0;
    const int page = 1 << 12;
    int nalloc;
    alloc += extra;
    if (alloc < 1<<6) {
        nalloc = (1<<3) + ((alloc >>3) << 3);
    } else  {
        // don't do anything if the loop will overflow signed int.
        if (alloc >= INT_MAX/2)
            return INT_MAX;
        nalloc = (alloc < page) ? 1 << 3 : page;
        while (nalloc < alloc) {
            if (nalloc <= 0)
                return INT_MAX;
            nalloc *= 2;
        }
    }
    return nalloc - extra;
}

private int grow(int size)
{
    // dear compiler: don't optimize me out.
    synchronized {
        int x = qAllocMore(size * (void*).sizeof, QListData.DataHeaderSize) / (void*).sizeof;
        return x;
    }
}

struct QListData {
    struct Data {
        Atomic!int ref_;
        int alloc, begin, end;
        uint sharable;
        void*[1] array;
    }
    
    enum { DataHeaderSize = Data.sizeof - (void*).sizeof }
    
    static Data shared_null;
    Data *d;
    
    static this()
    {
        shared_null = Data(Atomic!int(1), 0, 0, 0, true, [null]);
    }
    

//    Data *detach(); // remove in 5.0

    Data* detach2()
    {
        Data* x = d;
        d = cast(Data*)(qMalloc(DataHeaderSize + x.alloc * (void*).sizeof));
        if (!d)
            qFatal("QList: Out of memory");

        memcpy(d, x, DataHeaderSize + x.alloc * (void*).sizeof);
        d.alloc = x.alloc;
        d.ref_.store(1);
        d.sharable = true;
        if (!d.alloc)
            d.begin = d.end = 0;

        return x;
    }
    
    void realloc(int alloc)
    {
//        assert(d.ref_ == 1);
        Data* x = cast(Data*)(qRealloc(d, DataHeaderSize + alloc * (void*).sizeof));
        if (!x)
            qFatal("QList: Out of memory");

        d = x;
        d.alloc = alloc;
        if (!alloc)
            d.begin = d.end = 0;
    }
    
    void** append()
    {
// #TODO        Q_ASSERT(d.ref_ == 1);
        if (d.end == d.alloc) {
            int n = d.end - d.begin;
            if (d.begin > 2 * d.alloc / 3) {
                memcpy(d.array.ptr + n, d.array.ptr + d.begin, n * (void*).sizeof);
                d.begin = n;
                d.end = n * 2;
            } else {
                realloc(grow(d.alloc + 1));
            }
        }
        return d.array.ptr + d.end++;
    }

    void **append(const ref QListData l)
    {
//        Q_ASSERT(d.ref_ == 1);
        int e = d.end;
        int n = l.d.end - l.d.begin;
        if (n) {
            if (e + n > d.alloc)
                realloc(grow(e + l.d.end - l.d.begin));
            memcpy(d.array.ptr + d.end, l.d.array.ptr + l.d.begin, n * (void*).sizeof);
            d.end += n;
        }
        return d.array.ptr + e;
    }

    void **prepend()
    {
//        Q_ASSERT(d.ref_ == 1);
        if (d.begin == 0) {
            if (d.end >= d.alloc / 3)
                realloc(grow(d.alloc + 1));

            if (d.end < d.alloc / 3)
                d.begin = d.alloc - 2 * d.end;
            else
                d.begin = d.alloc - d.end;

            memmove(d.array.ptr + d.begin, d.array.ptr, d.end * (void*).sizeof);
            d.end += d.begin;
        }
        return d.array.ptr + --d.begin;
    }

    void **insert(int i)
    {
//        Q_ASSERT(d.ref_ == 1);
        if (i <= 0)
            return prepend();
        if (i >= d.end - d.begin)
            return append();

        bool leftward = false;
        int size = d.end - d.begin;

        if (d.begin == 0) {
            if (d.end == d.alloc) {
                // If the array is full, we expand it and move some items rightward
                realloc(grow(d.alloc + 1));
            } else {
                // If there is free space at the end of the array, we move some items rightward
            }
        } else {
            if (d.end == d.alloc) {
                // If there is free space at the beginning of the array, we move some items leftward
                leftward = true;
            } else {
                // If there is free space at both ends, we move as few items as possible
                leftward = (i < size - i);
            }
        }

        if (leftward) {
            --d.begin;
            memmove(d.array.ptr + d.begin, d.array.ptr + d.begin + 1, i * (void*).sizeof);
        } else {
            memmove(d.array.ptr + d.begin + i + 1, d.array.ptr + d.begin + i,
                    (size - i) * (void*).sizeof);
            ++d.end;
        }
        return d.array.ptr + d.begin + i;
    }

    void remove(int i)
    {
//        Q_ASSERT(d.ref_ == 1);
        i += d.begin;
        if (i - d.begin < d.end - i) {
            if (int offset = i - d.begin)
                memmove(d.array.ptr + d.begin + 1, d.array.ptr + d.begin, offset * (void*).sizeof);
            d.begin++;
        } else {
            if (int offset = d.end - i - 1)
                memmove(d.array.ptr + i, d.array.ptr + i + 1, offset * (void*).sizeof);
            d.end--;
        }
    }

    void remove(int i, int n)
    {
//        Q_ASSERT(d.ref_ == 1);
        i += d.begin;
        int middle = i + n/2;
        if (middle - d.begin < d.end - middle) {
            memmove(d.array.ptr + d.begin + n, d.array.ptr + d.begin,
                    (i - d.begin) * (void*).sizeof);
            d.begin += n;
        } else {
            memmove(d.array.ptr + i, d.array.ptr + i + n,
                    (d.end - i - n) * (void*).sizeof);
            d.end -= n;
        }
    }

    void move(int from, int to)
    {
//        Q_ASSERT(d.ref_ == 1);
        if (from == to)
            return;

        from += d.begin;
        to += d.begin;
        void *t = d.array.ptr[from];

        if (from < to) {
            if (d.end == d.alloc || 3 * (to - from) < 2 * (d.end - d.begin)) {
                memmove(d.array.ptr + from, d.array.ptr + from + 1, (to - from) * (void*).sizeof);
            } else {
                // optimization
                if (int offset = from - d.begin)
                    memmove(d.array.ptr + d.begin + 1, d.array.ptr + d.begin, offset * (void*).sizeof);
                if (int offset = d.end - (to + 1))
                    memmove(d.array.ptr + to + 2, d.array.ptr + to + 1, offset * (void*).sizeof);
                ++d.begin;
                ++d.end;
                ++to;
            }
        } else {
            if (d.begin == 0 || 3 * (from - to) < 2 * (d.end - d.begin)) {
                memmove(d.array.ptr + to + 1, d.array.ptr + to, (from - to) * (void*).sizeof);
            } else {
                // optimization
                if (int offset = to - d.begin)
                    memmove(d.array.ptr + d.begin - 1, d.array.ptr + d.begin, offset * (void*).sizeof);
                if (int offset = d.end - (from + 1))
                    memmove(d.array.ptr + from, d.array.ptr + from + 1, offset * (void*).sizeof);
                --d.begin;
                --d.end;
                --to;
            }
        }
        d.array.ptr[to] = t;
    }

    void **erase(void **xi)
    {
//        Q_ASSERT(d.ref_ == 1);
        int i = xi - (d.array.ptr + d.begin);
        remove(i);
        return d.array.ptr + d.begin + i;
    }

    int size() const { return d.end - d.begin; }
    bool isEmpty() const { return d.end  == d.begin; }
    const (void*)* at(int i) const { return d.array.ptr + d.begin + i; }
    const (void*)* begin() const { return d.array.ptr + d.begin; }
    const (void*)* end() const { return d.array.ptr + d.end; }
}

import std.stdio;

struct QList(T)
{
    struct Node
    {
        void *v;
    
        ref T t()
        { return *cast(T*)(&this); }
//        { return *cast(T*)(QTypeInfo!T.isLarge || QTypeInfo!T.isStatic
//                                       ? v : &this); }    }
    }
    
    union {
        QListData p;
        QListData.Data* d;
    }

public:
    void output()
    {
        writeln("QList atomic ", d.ref_.load());
    }
    
    static QList!T opCall()
    {
        QList!T res;
        writeln("QList opCall");
        
        res.d = &QListData.shared_null;
        res.d.ref_.increment();
        
        return res;
    }

    this(this)
    {
        writeln("QList postblit");
        d.ref_.increment();
        if (!d.sharable)
            detach_helper();
    }

    ~this()
    {
        writeln("QList ~this");
        if (d && !d.ref_.decrement())
            free(d);
    }

    ref QList!T opAssign(const ref QList!T l)
    {
        writeln("QList opAssign");
        if (d != l.d) {
            l.d.ref_.increment();
            if (!d.ref_.decrement())
                free(d);
            d = cast(QListData.Data*)l.d;
            if (!d.sharable)
                detach_helper();
        }
        return this;
    }
    
    void detach() { if (d.ref_.load() != 1) detach_helper(); }
    
    private void detach_helper()
    {
        Node *n = cast(Node*)(p.begin());
        QListData.Data* x = p.detach2();
        node_copy(cast(Node*)(p.begin()), cast(Node*)(p.end()), n);
        if (!x.ref_.decrement())
            free(x);
    }
    
    void append(const T t) // fix to const ref for complex types TODO
    {
        detach();
/*        static if (QTypeInfo!T.isLarge || QTypeInfo!T.isStatic)
        {
            node_construct(cast(Node*)(p.append()), t);
        }
        else*/
        {
            const T cpy = t;
            node_construct(cast(Node*)(p.append()), cpy);
        }
    }
    
    ref const (T) at(int i) const
    {
        assert(i >= 0 && i < p.size(), "QList!T.at(): index out of range");
        return (cast(Node*)(p.at(i))).t();
    }

    void node_construct(Node *n, const ref T t)
    {
/* TODO       static if (QTypeInfo!T.isLarge || QTypeInfo!T.isStatic)
            n.v = new T(t);
        else static if (QTypeInfo!T.isComplex)
            new (n) T(t);
        else*/
            *cast(T*)(n) = t;
    }
    
    void node_copy(Node *from, Node *to, Node *src)
    {
/* TODO       if (QTypeInfo<T>::isLarge || QTypeInfo<T>::isStatic)
            while(from != to)
                (from++)->v = new T(*reinterpret_cast<T*>((src++)->v));
        else if (QTypeInfo<T>::isComplex)
            while(from != to)
                new (from++) T(*reinterpret_cast<T*>(src++));
            */
    }

    void free(QListData.Data* data)
    {
        node_destruct(cast(Node*)(data.array.ptr + data.begin),
                      cast(Node*)(data.array.ptr + data.end));
        if (data.ref_.load() == 0)
            {} // qFree(data); TODO
    }
    
    void node_destruct(Node *from, Node *to)
    {/* TODO
        if (QTypeInfo!T.isLarge || QTypeInfo!T.isStatic)
            while (from != to) --to, delete cast(T*)(to->v);
        else if (QTypeInfo!T.isComplex)
            while (from != to) --to, cast(T*)(to).~T();
            */
    }
}

extern(C) void qtd_create_QList(void *nativeId);
