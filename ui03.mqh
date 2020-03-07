#property strict

enum E_FUNC {ONTICK, ONTIMER, ONTRADE, ONTESTER, ONCHARTEVENT, ONBOOKEVENT};


class UI
{
public:
	long        chart_id;
	string      name;
	ENUM_OBJECT type;
	int         nwin;
	datetime    time1;
	double      price1;

	UI(long chart_id, string name, ENUM_OBJECT type, int nwin, datetime time1,
	   double price1);
	~UI();
	static double ui(const E_FUNC FUNC, const int id, const long &lparam,
	                 const double &dparam, const string &sparam);
};

UI::UI(long chart_id, string name, ENUM_OBJECT type, int nwin, datetime time1,
       double price1)
{
	this.chart_id = chart_id;
	this.name     = name;
	this.type     = type;
	this.nwin     = nwin;
	this.time1    = time1;
	this.price1   = price1;
}

UI::~UI()
{
	ObjectDelete(chart_id, name);
}


class Button : public UI
{
public:
	string text;
	long   corner;
	int    xsize;
	int    ysize;
	int    xdistance;
	int    ydistance;
	long   zorder;
	bool   readonly;

	Button(long chart_id, string name, ENUM_OBJECT type, int nwin,
	       datetime time1, double price1, string text, long corner, int xsize,
	       int ysize, int xdistance, int ydistance, long zorder, bool readonly);
	void change_text(string text);
	void text_edited();
	void change_bgcolor(color clr);
};

Button::Button(long chart_id, string name, ENUM_OBJECT type, int nwin,
               datetime time1, double price1, string text, long corner,
               int xsize, int ysize, int xdistance, int ydistance, long zorder,
               bool readonly) : UI(chart_id, name, type, nwin, time1, price1)
{
	this.text      = text;
	this.corner    = corner;
	this.xsize     = xsize;
	this.ysize     = ysize;
	this.xdistance = xdistance;
	this.ydistance = ydistance;
	this.zorder    = zorder;
	this.readonly  = readonly;

	ObjectCreate(chart_id, name, type, nwin, time1, price1);
	ObjectSetString(chart_id, name, OBJPROP_TEXT, text);
	ObjectSetInteger(chart_id, name, OBJPROP_CORNER, corner);
	ObjectSetInteger(chart_id, name, OBJPROP_XSIZE, xsize);
	ObjectSetInteger(chart_id, name, OBJPROP_YSIZE, ysize);
	ObjectSetInteger(chart_id, name, OBJPROP_XDISTANCE, xdistance);
	ObjectSetInteger(chart_id, name, OBJPROP_YDISTANCE, ydistance);
	ObjectSetInteger(chart_id, name, OBJPROP_SELECTABLE, false);
	ObjectSetInteger(chart_id, name, OBJPROP_ZORDER, zorder);
	ObjectSetInteger(chart_id, name, OBJPROP_READONLY, readonly);
	ObjectSetInteger(chart_id, name, OBJPROP_ALIGN, ALIGN_CENTER);
}

void Button::change_text(string text)
{
	ObjectSetString(chart_id, name, OBJPROP_TEXT, text);
	this.text = text;
}

void Button::text_edited()
{
	text = ObjectGetString(chart_id, name, OBJPROP_TEXT);
}

void Button::change_bgcolor(color clr)
{
	ObjectSetInteger(chart_id, name, OBJPROP_BGCOLOR, clr);
}


class CheckBox : public UI
{
public:
	bool state;
	long corner;
	int  xsize;
	int  ysize;
	int  xdistance;
	int  ydistance;
	long zorder;
	bool readonly;

	CheckBox(long chart_id, string name, int nwin,
	         datetime time1, double price1, bool state,
	         int xdistance, int ydistance, long zorder);
	void enable();
	void disable();
	bool get_state();
	void toggle();
};

CheckBox::CheckBox(long chart_id, string name, int nwin,
                   datetime time1, double price1, bool state,
                   int xdistance, int ydistance,
                   long zorder) : UI(chart_id, name, type, nwin, time1, price1)
{
	this.state     = state;
	this.corner    = CORNER_LEFT_UPPER;
	this.xsize     = 16;
	this.ysize     = 16;
	this.xdistance = xdistance;
	this.ydistance = ydistance;
	this.zorder    = zorder;
	this.readonly  = readonly;

	ObjectCreate(chart_id, name, OBJ_EDIT, nwin, time1, price1);
	if (state)
		ObjectSetString(chart_id, name, OBJPROP_TEXT, "X");
	else
		ObjectSetString(chart_id, name, OBJPROP_TEXT, "");
	ObjectSetInteger(chart_id, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
	ObjectSetInteger(chart_id, name, OBJPROP_BGCOLOR, clrWhite);
	ObjectSetInteger(chart_id, name, OBJPROP_XSIZE, this.xsize);
	ObjectSetInteger(chart_id, name, OBJPROP_YSIZE, this.ysize);
	ObjectSetInteger(chart_id, name, OBJPROP_XDISTANCE, xdistance);
	ObjectSetInteger(chart_id, name, OBJPROP_YDISTANCE, ydistance);
	ObjectSetInteger(chart_id, name, OBJPROP_SELECTABLE, false);
	ObjectSetInteger(chart_id, name, OBJPROP_ZORDER, zorder);
	ObjectSetInteger(chart_id, name, OBJPROP_READONLY, true);
	ObjectSetInteger(chart_id, name, OBJPROP_ALIGN, ALIGN_CENTER);
}

void CheckBox::enable()
{
	ObjectSetString(chart_id, name, OBJPROP_TEXT, "X");
	state = true;
}

void CheckBox::disable()
{
	ObjectSetString(chart_id, name, OBJPROP_TEXT, "");
	state = false;
}

bool CheckBox::get_state()
{
	return state;
}

void CheckBox::toggle()
{
	if (get_state())
		disable();
	else
		enable();
}
