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
	if (reason == REASON_REMOVE || reason == REASON_RECOMPILE) {
		EventKillTimer();
		DeleteButtons();
		ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, false);
		ChartRedraw();
	}
}

void OnTick()
{
}

void OnTimer()
{
}

void OnChartEvent(const int id,
                  const long &lparam,    // x
                  const double &dparam,  // y
                  const string &sparam)
                  // mouse_up, mouse_down (MOUSE_MOVE
                  // name of the object, on which the event occurred (OBJECT_CLK
{
	int      x      = (int)lparam;
	int      y      = (int)dparam;
	int      window = WRONG_VALUE;
	datetime time   = NULL;
	double   price  = 0.0;

	if (id == CHARTEVENT_MOUSE_MOVE) {
		ChangeButtonColorOnHover(x, y);

		if (ChartXYToTimePrice(0, x, y, window, time, price)) {
			price = WindowPriceMin() * 2 - price;
			Comment("id: ", CHARTEVENT_MOUSE_MOVE, "\n",
			        "x: ", x, "\n",  // 最小値が 3 なのは，チャートの枠内だけに
			        "y: ", y, "\n",  // 注目してる関数だから
			        "sparam (state of the mouse buttons): ", sparam, "\n",
			        "window: ", window, "\n",
			        "time: ", time, "\n",
			        "price: ", DoubleToString(price, _Digits));
		}

		return;  // OnChartEvent() は，一回呼ばれたら一つのイベントだけのはず
		         // そういう意味では case 文のがいいのかもしれない…
	}

	if (id == CHARTEVENT_OBJECT_CLICK) {
		Print("CHARTEVENT_OBJECT_CLICK");
		Print(sparam);
		ObjectSetString(0, sparam, OBJPROP_TEXT, "fuga");
		new_position();

		return;
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

void new_position()
{
	int Ticket;

	Print(Ask);
	Print(Bid);
	//MqlTradeRequest req;
	//MqlTradeResult  res;

	//req.action = TRADE_ACTION_DEAL;

	//Ticket = OrderSend("EURJPY", OP_BUY, 0.01, Ask, 1, Ask - 0.2, 0,
	//                   "(｀・ω・´)", 0, 0, clrRed);
	Ticket = OrderSend(Symbol(), OP_BUY, 0.1, Ask, 10, Ask - 0.2, 0,
	                   NULL, 0, 0, Red);
	Print(Ticket);
}

void DeleteButtons()
{
	DeleteObjectByName("hoge");
}

void DeleteObjectByName(string object_name)
{
	if (ObjectFind(0, object_name) >= 0)  // if such object exists
		if(!ObjectDelete(0, object_name))
			Print("error (" + IntegerToString(GetLastError())
			      + ") when deleting the object!");
}
