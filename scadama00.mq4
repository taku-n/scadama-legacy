#property strict

#property version "1.00"

int OnInit()
{
	EventSetTimer(1);  // 1second intervals
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
		ObjectSetInteger(id, name, OBJPROP_XDISTANCE, 32);
		ObjectSetInteger(id, name, OBJPROP_YDISTANCE, 32);
		ObjectSetInteger(id, name, OBJPROP_SELECTABLE, false);
		ObjectSetInteger(id, name, OBJPROP_ZORDER, 2);
		ObjectSetInteger(id, name, OBJPROP_READONLY, true);  // read only text
		ObjectSetInteger(id, name, OBJPROP_ALIGN, ALIGN_CENTER);
	}
}
