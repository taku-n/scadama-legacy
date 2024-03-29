#property strict

#property version "1.00"

int OnInit()
{
	EventSetTimer(1);  // 1second intervals
	// bool EventSetTimer(int seconds);
	ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
	// enable tracking of mouse events
	AddButtonsPanel();
	ChartRedraw();

	return 0;
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
}

void OnTimer()
{
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
	int      x      = (int)lparam;
	int      y      = (int)dparam;
	int      window = WRONG_VALUE;
	datetime time   = NULL;
	double   price  = 0.0;

	if (id == CHARTEVENT_MOUSE_MOVE) {
		ChangeButtonColorOnHover(x, y);

		if (ChartXYToTimePrice(0, x, y, window, time, price)) {
			Comment("id: ", CHARTEVENT_MOUSE_MOVE, "\n",
			        "x: ", x, "\n",  // 最小値が 3 なのは，チャートの枠内だけに
			        "y: ", y, "\n",  // 注目してる関数だから
			        "sparam (state of the mouse buttons): ", sparam, "\n",
			        "window: ", window, "\n",
			        "time: ", time, "\n",
			        "price: ", DoubleToString(price, _Digits));
		}
	}

	ChartRedraw();
}

void AddButtonsPanel()
{
	CreateButton(0, 0);
}

void CreateButton(long chart_id,
                  int  sub_window)
{
	long id = chart_id;
	string name = "hoge";

	if (ObjectCreate(id, name, OBJ_EDIT, 0, 0, 0)) {
		ObjectSetString(id, name, OBJPROP_TEXT, "hoge");
		ObjectSetInteger(id, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
		ObjectSetInteger(id, name, OBJPROP_XSIZE, 32);
		ObjectSetInteger(id, name, OBJPROP_YSIZE, 32);
		ObjectSetInteger(id, name, OBJPROP_XDISTANCE, 128);
		ObjectSetInteger(id, name, OBJPROP_YDISTANCE, 128);
		ObjectSetInteger(id, name, OBJPROP_SELECTABLE, false);
		ObjectSetInteger(id, name, OBJPROP_ZORDER, 2);
		ObjectSetInteger(id, name, OBJPROP_READONLY, true);  // read only text
		ObjectSetInteger(id, name, OBJPROP_ALIGN, ALIGN_CENTER);
	}
}

void ChangeButtonColorOnHover(int x, int y)
{
	int x1, y1, x2, y2;

	x1 = 128;
	y1 = 128;
	x2 = 128 + 32;
	y2 = 128 + 32;

	if (x > x1 && x < x2 && y > y1 && y < y2)
		ObjectSetInteger(0, "hoge", OBJPROP_BGCOLOR, clrRed);
	else
		ObjectSetInteger(0, "hoge", OBJPROP_BGCOLOR, clrBlue);
}
