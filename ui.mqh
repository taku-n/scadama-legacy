#property strict

#ifndef UI_MQH
#define UI_MQH

#include "obj0200.mqh"

enum E_EVENT_TYPE {ON_TICK, ON_TIMER, ON_TRADE, ON_TESTER, ON_CHARTEVENT, ON_BOOKEVENT};


class UI : public Obj
{
public:
	ENUM_OBJECT type;
	int         nwin;
	datetime    time1;
	double      price1;

	UI(long chart_id, string name, ENUM_OBJECT type, int nwin, datetime time1,
	   double price1) : Obj(chart_id, name), type(type), nwin(nwin),
	                    time1(time1), price1(price1)
	{
	}

	// virtual destractor
	virtual ~UI()
	{
	}

	static double ui(const E_FUNC FUNC, const int id, const long &lparam,
	                 const double &dparam, const string &sparam);
};


class Button : public UI
{
public:
	string          text;
	long            corner;
	int             xsize;
	int             ysize;
	int             xdistance;
	int             ydistance;
	long            zorder;
	bool            readonly;
	ENUM_ALIGN_MODE align;

	Button(long chart_id, string name, ENUM_OBJECT type, int nwin,
	       datetime time1, double price1
	      );
	Button(long chart_id, string name, ENUM_OBJECT type, int nwin,
	       datetime time1, double price1, string text, long corner, int xsize,
	       int ysize, int xdistance, int ydistance, long zorder, bool readonly);
	Button *set_text(string text);

	Button *set_w(int width)
	{
		ObjectSetInteger(chart_id, name, OBJPROP_XSIZE, width);
		xsize = width;

		return GetPointer(this);
	}

	Button *set_h(int height)
	{
		ObjectSetInteger(chart_id, name, OBJPROP_YSIZE, height);
		ysize = height;

		return GetPointer(this);
	}

	Button *set_x(int x)
	{
		ObjectSetInteger(chart_id, name, OBJPROP_XDISTANCE, x);
		xdistance = x;

		return GetPointer(this);
	}

	Button *set_y(int y)
	{
		ObjectSetInteger(chart_id, name, OBJPROP_YDISTANCE, y);
		ydistance = y;

		return GetPointer(this);
	}

	void text_edited();

	Button *set_fontsize(int font_size)
	{
		ObjectSetInteger(get_chart_id(), get_name(),
		                 OBJPROP_FONTSIZE, font_size);

		return GetPointer(this);		                 
	}

	Button *set_fontcolor(color clr);
	Button *set_align(ENUM_ALIGN_MODE E_ALIGN);

	Button *set_border_type(ENUM_BORDER_TYPE E_TYPE)
	{
		ObjectSetInteger(get_chart_id(), get_name(),
		                 OBJPROP_BORDER_TYPE, E_TYPE
		                );

		return GetPointer(this);		                
	}

	Button *set_border_color(color clr)
	{
		ObjectSetInteger(get_chart_id(), get_name(),
		                 OBJPROP_BORDER_COLOR, clr
		                );

		return GetPointer(this);
	}

	Button *set_bgcolor(color clr)
	{
		ObjectSetInteger(chart_id, name, OBJPROP_BGCOLOR, clr);

		return GetPointer(this);
	}

	Button *set_readonly(bool readonly)
	{
		ObjectSetInteger(chart_id, name, OBJPROP_READONLY, readonly);
		this.readonly = readonly;

		return GetPointer(this);
    }
};

Button::Button(long chart_id, string name, ENUM_OBJECT type, int nwin,
               datetime time1, double price1
              ) : UI(chart_id, name, type, nwin, time1, price1), text(""),
                  corner(CORNER_LEFT_UPPER), xsize(10), ysize(10),
                  xdistance(10), ydistance(10), zorder(2), readonly(true),
                  align(ALIGN_CENTER)
{
	ObjectCreate(chart_id, name, type, 0, 0, 0);
	ObjectSetString(chart_id, name, OBJPROP_TEXT, text);
	ObjectSetInteger(chart_id, name, OBJPROP_CORNER,     corner);
	ObjectSetInteger(chart_id, name, OBJPROP_XSIZE,      xsize);
	ObjectSetInteger(chart_id, name, OBJPROP_YSIZE,      ysize);
	ObjectSetInteger(chart_id, name, OBJPROP_XDISTANCE,  xdistance);
	ObjectSetInteger(chart_id, name, OBJPROP_YDISTANCE,  ydistance);
	ObjectSetInteger(chart_id, name, OBJPROP_SELECTABLE, false);
	ObjectSetInteger(chart_id, name, OBJPROP_ZORDER,     zorder);
	ObjectSetInteger(chart_id, name, OBJPROP_READONLY,   readonly);
	ObjectSetInteger(chart_id, name, OBJPROP_ALIGN,      align);
}

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

Button *Button::set_text(string text)
{
	ObjectSetString(chart_id, name, OBJPROP_TEXT, text);
	this.text = text;

	return GetPointer(this);
}

void Button::text_edited()
{
	text = ObjectGetString(chart_id, name, OBJPROP_TEXT);
}

Button *Button::set_fontcolor(color clr)
{
	ObjectSetInteger(chart_id, name, OBJPROP_COLOR, clr);

	return GetPointer(this);
}

Button *Button::set_align(ENUM_ALIGN_MODE E_ALIGN)
{
	ObjectSetInteger(chart_id, name, OBJPROP_ALIGN, E_ALIGN);
	this.align = E_ALIGN;

	return GetPointer(this);
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


#endif
