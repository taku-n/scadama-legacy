#property strict

#ifndef OBJ_MQH
#define OBJ_MQH

// ユーザインタフェースオブジェクトの管理をする双方向リスト
// Objs クラスが双方向リスト
// Obj クラスがその要素


// 双方向リストの各要素
class Obj
{
protected:
	long   chart_id;
	string name;

public:
	Obj    *prev;  // a pointer to the previous element
	Obj    *next;  // a pointer to the next element

	Obj(long chart_id, string name) : chart_id(chart_id), name(name),
	                                  prev(NULL), next(NULL)
	{
	}

	// virtual destructor
	virtual ~Obj()
	{
		ObjectDelete(chart_id, name);  // remove the graphic object
	}

	long get_chart_id()
	{
		return chart_id;
	}

	string get_name()
	{
		return name;
	}
};


// doubly-linked list
class Objs
{
	static Obj  root;  // the root node

	// the recursive function for dlt_all()
	static void dlt_all_recursive(Obj *p);

public:
	static Obj  *add(Obj *p_new_obj);
	static void  dlt(string name);
	static void  dlt_all();

	// return the pointer
	static Obj  *get(string name);
	static void  print_all();
};


Obj Objs::root(0, NULL);

void Objs::dlt_all_recursive(Obj *p)
{
	if (p.next != NULL)
		dlt_all_recursive(p.next);

	delete p;
}

Obj *Objs::add(Obj *p_new_obj)
{
	Obj *p = (Obj *)GetPointer(root);

	// find out the last element
	while (p.next != NULL)
		p = p.next;

	// p is a pointer to the last element
	// p_new_obj is a pointer to the new object being added
	p.next = p_new_obj;
	p_new_obj.prev = p;

	return p_new_obj;
}

void Objs::dlt(string name)
{
	Obj *p = (Obj *)GetPointer(root);
	Obj *q;

	do {
		if (p.get_name() == name) {
			q.next = p.next;
			if (p.next != NULL)
				p.next.prev = q;
			delete p;
			return;
		} else
			q = p;
	} while ((p = p.next) != NULL);
}

void Objs::dlt_all()
{
	dlt_all_recursive(root.next);
	root.next = NULL;
}

Obj *Objs::get(string name)
{
	Obj *p = (Obj *)GetPointer(root);

	while (p.get_name() != name)
		if ((p = p.next) == NULL)
			return NULL;

	return p;
}

void Objs::print_all()
{
	Obj *p = root.next;

	if (root.next == NULL) {
		Print("there is no Obj");
		return;
	}

	do {
		Print("(chart_id, name) = (",
		      p.get_chart_id(), ", ", p.get_name(), ")");
	} while ((p = p.next) != NULL);
}


#endif