#property strict

#ifndef OBJ_MQH
#define OBJ_MQH


class Obj
{
public:
	string  name;
	Obj    *next;

	Obj(string name);
	virtual ~Obj();    // virtual destructor
};


class Objs
{
	static Obj *p_root;

	static void dlt_all_recursive(Obj *p);

public:
	static Obj  *add(Obj *p_o);
	static void  dlt(string name);
	static void  dlt_all();
	static Obj  *get(string name);
	static void  print_all();
};


Obj::Obj(string name) : name(name), next(NULL)
{
}

Obj::~Obj()
{
}


Obj *Objs::p_root = NULL;

void Objs::dlt_all_recursive(Obj *p)
{
	if (p.next != NULL)
		dlt_all_recursive(p.next);

	delete p;
}

Obj *Objs::add(Obj *p_o)
{
	Obj *p = p_root;

	if (p_root == NULL) {
		p_root = p_o;
		return p_o;
	}

	while (p.next != NULL)
		p = p.next;

	p.next = p_o;

	return p_o;
}

void Objs::dlt(string name)
{
	Obj *p = p_root;
	Obj *q;

	if ((q = get(name)) == NULL) {
		Print("there is not such a Obj");
		return;
	}

	// if it is the first Obj
	if (q == p_root) {
		p_root = p_root.next;
		delete q;
		return;
	}

	// p will be a pointer before the Obj being deleted
	while (p.next.name != name)
		p = p.next;

	q = p.next;
	p.next = q.next;
	delete q;
}

void Objs::dlt_all()
{
	if (p_root != NULL) {
		dlt_all_recursive(p_root);
		p_root = NULL;
	}
}

Obj *Objs::get(string name)
{
	Obj *p = p_root;

	if (p_root == NULL)
		return NULL;

	while (p.name != name)
		if ((p = p.next) == NULL) {
			Print("there is not a Obj having such a name");
			return NULL;
		}

	return p;
}

void Objs::print_all()
{
	Obj *p = p_root;

	if (p_root == NULL) {
		Print("there is no Obj");
		return;
	}

	do {
		Print(p.name);
	} while ((p = p.next) != NULL);
}


#endif