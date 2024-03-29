#property strict

#property version "1.00"

#include "ui03.mqh"
#include "price00.mqh"

int OnInit()
{
	ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);

	ChartRedraw();
	return 0;
}

void OnDeinit(const int reason)
{
	ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, false);

	ChartRedraw();
}

double UI::ui(const E_FUNC FUNC, const int id, const long &lparam,
              const double &dparam, const string &sparam)
{
	static Button bid(0, "bid", OBJ_EDIT, 0, 0, 0, "", CORNER_LEFT_UPPER,
	                  60, 30, 0, 0, 2, true);
	static Button ask(0, "ask", OBJ_EDIT, 0, 0, 0, "", CORNER_LEFT_UPPER,
	                  60, 30, 60, 0, 2, true);
	static Button spread(0, "spread", OBJ_EDIT, 0, 0, 0, "", CORNER_LEFT_UPPER,
	                  60, 30, 30, 30, 2, true);
	static Button button0(0, "btn0", OBJ_EDIT, 0, 0, 0, "hoge",
	                      CORNER_LEFT_UPPER, 32, 32, 128, 128, 2, true);
	static Button button1(0, "btn1", OBJ_EDIT, 0, 0, 0, "fuga",
	                      CORNER_LEFT_UPPER, 32, 32, 256, 128, 2, true);
	static Button button2(0, "btn2", OBJ_EDIT, 0, 0, 0, "piyo",
	                      CORNER_LEFT_UPPER, 32, 32, 256, 256, 2, false);
	static CheckBox checkbox0(0, "check0", 0, 0, 0, true, 128, 256, 2);

	switch (FUNC) {
	case ONTICK:
		Price::set_bid(SymbolInfoDouble(_Symbol, SYMBOL_BID));
		Price::set_ask(SymbolInfoDouble(_Symbol, SYMBOL_ASK));
		bid.change_text(DoubleToString(Price::BID, 3));
		ask.change_text(DoubleToString(Price::ASK, 3));
		spread.change_text(DoubleToString(Price::SPREAD, 1));
		break;
	case ONTIMER:
		break;
	case ONTRADE:
		break;
	case ONTESTER:
		break;
	case ONCHARTEVENT:
		switch (id) {
		case CHARTEVENT_OBJECT_CLICK:
		// lparam: the X coordinate, dparam: the Y coordinate
		// sparam: Name of the graphical object, on which the event occurred
			if (sparam == "btn0")
				button0.change_text("piyo");
			else if (sparam == "btn1")
				button1.change_text("foo");
			else if (sparam == "check0")
				checkbox0.toggle();
			else if (sparam == "bid")
				OrderSend(Symbol(), OP_SELL, 0.01, Price::BID, 1,
				          Price::BID + 0.2, 0, NULL, 0, 0, Blue);
			else if (sparam == "ask")
				OrderSend(Symbol(), OP_BUY, 0.01, Price::ASK, 1,
				          Price::ASK - 0.2, 0, NULL, 0, 0, Red);
			break;
		case CHARTEVENT_OBJECT_ENDEDIT:
		// sparam: Name of LabelEdit obj., in which text editing has completed
			if (sparam == "btn2")
				button2.text_edited();
			break;
		}
		break;
	case ONBOOKEVENT:
		break;
	}

	return 0.0;
}

void OnTick()
{
	long   lparam;
	double dparam;
	string sparam;

	UI::ui(ONTICK, 0, lparam, dparam, sparam);
}

void OnChartEvent(const int id, const long &lparam,
                  const double &dparam, const string &sparam)
{
	UI::ui(ONCHARTEVENT, id, lparam, dparam, sparam);
}
