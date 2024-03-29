#property strict

#property version "1.00"

#include "ui05.mqh"
#include "price01.mqh"
#include "trade02.mqh"
#include "status01.mqh"

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

	Status::destructor();
}

double UI::ui(const E_FUNC FUNC, const int id, const long &lparam,
              const double &dparam, const string &sparam)
{
	static bool initialized = false;
	static Trade trade();

	static Button bid(0, "bid", OBJ_EDIT, 0, 0, 0, "", CORNER_LEFT_UPPER,
	                  60, 30, 0, 20, 2, true);
	static Button ask(0, "ask", OBJ_EDIT, 0, 0, 0, "", CORNER_LEFT_UPPER,
	                  60, 30, 60, 20, 2, true);
	static Button spread(0, "spread", OBJ_EDIT, 0, 0, 0, "", CORNER_LEFT_UPPER,
	                  60, 20, 30, 50, 2, true);
	static Button lot(0, "lot", OBJ_EDIT, 0, 0, 0, "0.01", CORNER_LEFT_UPPER,
	                  60, 30, 30, 70, 2, false);
	static Button close_all(0, "close_all", OBJ_EDIT, 0, 0, 0, "CLOSE",
	                        CORNER_LEFT_UPPER, 60, 30, 30, 100, 2, true);
	static Button even(0, "even", OBJ_EDIT, 0, 0, 0, "EVEN", CORNER_LEFT_UPPER,
	                   60, 30, 30, 130, 2, true);
	static CheckBox checkbox0(0, "check0", 0, 0, 0, true, 128, 256, 2);

	if (!initialized) {
		bid.change_fontcolor(clrWhite);
		ask.change_fontcolor(clrWhite);
		spread.change_fontcolor(clrWhite);
		close_all.change_bgcolor(clrYellow);
		Status::status = new Button(0, "status", OBJ_EDIT, 0, 0, 0, "",
		                            CORNER_LEFT_UPPER, 300, 20, 0, 0, 2,
		                            true);
		Status::status.change_align(ALIGN_LEFT);

		initialized = true;
	}

	switch (FUNC) {
	case ONTICK:
		Price::set_bid(SymbolInfoDouble(_Symbol, SYMBOL_BID));
		Price::set_ask(SymbolInfoDouble(_Symbol, SYMBOL_ASK));
		Price::set_spread();

		bid.change_text(DoubleToString(Price::BID, 3));
		if (Price::BID > Price::SECOND_LAST_BID)
			bid.change_bgcolor(clrCrimson);
		else if (Price::BID < Price::SECOND_LAST_BID)
			bid.change_bgcolor(clrBlue);

		ask.change_text(DoubleToString(Price::ASK, 3));
		if (Price::ASK > Price::SECOND_LAST_ASK)
			ask.change_bgcolor(clrCrimson);
		else if (Price::ASK < Price::SECOND_LAST_ASK)
			ask.change_bgcolor(clrBlue);

		spread.change_text(DoubleToString(Price::SPREAD, 1));
		if (Price::SPREAD > Price::SECOND_LAST_SPREAD)
			spread.change_bgcolor(clrCrimson);
		else if (Price::SPREAD < Price::SECOND_LAST_SPREAD)
			spread.change_bgcolor(clrBlue);

		if (trade.even_ok())
			even.change_bgcolor(clrGreen);
		else
			even.change_bgcolor(clrWhite);

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
			if (sparam == "check0")
				checkbox0.toggle();
			else if (sparam == "bid")
				trade.bid();
			else if (sparam == "ask")
				trade.ask();
			else if (sparam == "close_all")
				trade.close_all();
			else if (sparam == "even")
				if (trade.even_ok())
					trade.even();
			break;
		case CHARTEVENT_OBJECT_ENDEDIT:
		// sparam: Name of LabelEdit obj., in which text editing has completed
			if (sparam == "lot") {
				lot.text_edited();
				trade.lot = StringToDouble(lot.text);
				if (trade.lot < MarketInfo(Symbol(), MODE_MINLOT))
					Status::msg("invalid amount of a lot");
				else
					Status::msg("");
			}
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
