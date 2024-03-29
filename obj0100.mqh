#property strict

#ifndef OBJ_MQH
#define OBJ_MQH


class Obj
{
public:
	long    chart_id;
	string  name;
	Obj    *next;

	Obj(long chart_id, string name) : chart_id(chart_id), name(name), next(NULL)
	{
	}

	// virtual destructor
	virtual ~Obj()
	{
		ObjectDelete(chart_id, name);
	}
};


class Objs
{
	static Obj  root;

	static void dlt_all_recursive(Obj *p);

public:
	static Obj  *add(Obj *p_o);
	static void  dlt(string name);
	static void  dlt_all();
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

Obj *Objs::add(Obj *p_o)
{
	Obj *p = (Obj *)GetPointer(root);

	while (p.next != NULL)
		p = p.next;

	p.next = p_o;

	return p_o;
}

void Objs::dlt(string name)
{
	Obj *p = (Obj *)GetPointer(root);
	Obj *q;

	do {
		if (p.name == name) {
			q.next = p.next;
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

	while (p.name != name)
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
		Print("(chart_id, name) = (", p.chart_id, ", ", p.name, ")");
	} while ((p = p.next) != NULL);
}


#endif