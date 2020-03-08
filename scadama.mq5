#property strict

///////////////////////////////////////////////////////////
// First of all, you should check the Take Profit Margin //
// and the Stop Loss Margin of your broker               //
// because it can cause a trouble in debug.              //
///////////////////////////////////////////////////////////

#property version "2.0.0"

#include "ui.mqh"
#include "price.mqh"
#include "trade.mqh"
#include "status.mqh"
#include "account.mqh"
#include "symbol.mqh"


//////////////////
//// OnInit() ////
//////////////////

int OnInit()
{
	//-- remove_ea --//

	Objs::add((new Button(0, "remove_ea", OBJ_EDIT, 0, 0, 0))
	          .set_text("X")
	          .set_w(20)
	          .set_h(20)
	          .set_x(10)
	          .set_y(10)
	         );


	//-- status --//

	Status::status = (new Button(0, "status", OBJ_EDIT, 0, 0, 0))
	                 .set_w(360)
	                 .set_h(20)
	                 .set_x(40)
	                 .set_y(10)
	                 .set_align(ALIGN_LEFT);


	//-- bid and ask button --//

	const int BID_X        =  10;
	const int BID_Y        =  40;
	const int ASK_X        = 170;
	const int ASK_Y        =  40;
	const int PRICE_MORE_W =  35;  // bid ボタンと ask ボタンの上位桁の幅
	const int PRICE_MID_W  =  40;  // bid ボタンと ask ボタンの中位桁の幅
	const int PRICE_LESS_W =  25;  // bid ボタンと ask ボタンの下位桁の幅
	const int PRICE_H      =  40;  // bid ボタンと ask ボタンの高さ

	Objs::add((new Button(0, "bid_more", OBJ_EDIT, 0, 0, 0))
	          .set_w(PRICE_MORE_W)
	          .set_h(PRICE_H)
	          .set_x(BID_X)
	          .set_y(BID_Y)
	          .set_fontsize(10)
	          .set_border_type(BORDER_RAISED)
	          .set_fontcolor(clrWhite)
	         );

	Objs::add((new Button(0, "bid_mid", OBJ_EDIT, 0, 0, 0))
	          .set_w(PRICE_MID_W)
	          .set_h(PRICE_H)
	          .set_x(BID_X + PRICE_MORE_W)
	          .set_y(BID_Y)
	          .set_fontsize(22)
	          .set_border_type(BORDER_RAISED)
	          .set_fontcolor(clrWhite)
	         );

	Objs::add((new Button(0, "bid_less", OBJ_EDIT, 0, 0, 0))
	          .set_w(PRICE_LESS_W)
	          .set_h(PRICE_H)
	          .set_x(BID_X + PRICE_MORE_W + PRICE_MID_W)
	          .set_y(BID_Y)
	          .set_fontsize(14)
	          .set_border_type(BORDER_RAISED)
	          .set_fontcolor(clrWhite)
	         );

	Objs::add((new Button(0, "ask_more", OBJ_EDIT, 0, 0, 0))
	          .set_w(PRICE_MORE_W)
	          .set_h(PRICE_H)
	          .set_x(ASK_X)
	          .set_y(ASK_Y)
	          .set_fontsize(10)
	          .set_border_type(BORDER_RAISED)
	          .set_fontcolor(clrWhite)
	         );

	Objs::add((new Button(0, "ask_mid", OBJ_EDIT, 0, 0, 0))
	          .set_w(PRICE_MID_W)
	          .set_h(PRICE_H)
	          .set_x(ASK_X + PRICE_MORE_W)
	          .set_y(ASK_Y)
	          .set_fontsize(22)
	          .set_border_type(BORDER_RAISED)
	          .set_fontcolor(clrWhite)
	         );

	Objs::add((new Button(0, "ask_less", OBJ_EDIT, 0, 0, 0))
	          .set_w(PRICE_LESS_W)
	          .set_h(PRICE_H)
	          .set_x(ASK_X + PRICE_MORE_W + PRICE_MID_W)
	          .set_y(ASK_Y)
	          .set_fontsize(14)
	          .set_border_type(BORDER_RAISED)
	          .set_fontcolor(clrWhite)
	         );


	//-- spread --//

	Objs::add((new Button(0, "spread", OBJ_EDIT, 0, 0, 0))
	          .set_w(40)
	          .set_h(20)
	          .set_x(120)
	          .set_y(50)
	          .set_fontcolor(clrWhite)
	         );


	//-- lot --//

	Objs::add((new Button(0, "lot", OBJ_EDIT, 0, 0, 0))
	          .set_text("0.01")
	          .set_w(60)
	          .set_h(30)
	          .set_x(110)
	          .set_y(90)
	          .set_readonly(false)
	         );


	//-- auto_sl --//

	Objs::add((new Button(0, "auto_sl", OBJ_EDIT, 0, 0, 0))
	          .set_w(60)
	          .set_h(30)
	          .set_x(110)
	          .set_y(135)
	          .set_readonly(false)
	         );


	//-- square --//

	Objs::add((new Button(0, "square", OBJ_EDIT, 0, 0, 0))
	          .set_text("SQUARE")
	          .set_fontsize(9)
	          .set_w(60)
	          .set_h(30)
	          .set_x(110)
	          .set_y(180)
	         );


	//-- close --//

	Objs::add((new Button(0, "close", OBJ_EDIT, 0, 0, 0))
	          .set_text("CLOSE")
	          .set_w(60)
	          .set_h(30)
	          .set_x(110)
	          .set_y(225)
	          .set_bgcolor(clrYellow)
	         );


	//-- close_all --//

	Objs::add((new Button(0, "close_all", OBJ_EDIT, 0, 0, 0))
              .set_text("CLSALL")
              .set_w(60)
              .set_h(30)
              .set_x(110)
	          .set_y(270)
	          .set_fontcolor(clrBlack)
	          .set_bgcolor(clrOrange)
	         );


	//-- lot_sell --//

	Objs::add((new Button(0, "lot_sell", OBJ_EDIT, 0, 0, 0))
	          .set_w(60)
	          .set_h(20)
	          .set_x(30)
	          .set_y(90)
	         );


	//-- lot_buy --//

	Objs::add((new Button(0, "lot_buy", OBJ_EDIT, 0, 0, 0))
	          .set_w(60)
	          .set_h(20)
	          .set_x(190)
	          .set_y(90)
	         );


	//-- ave_sell --//

	Objs::add((new Button(0, "ave_sell", OBJ_EDIT, 0, 0, 0))
	          .set_w(60)
	          .set_h(20)
	          .set_x(30)
	          .set_y(120)
	         );


	//-- ave_buy --//

	Objs::add((new Button(0, "ave_buy", OBJ_EDIT, 0, 0, 0))
	          .set_w(60)
	          .set_h(20)
	          .set_x(190)
	          .set_y(120)
	         );


	//-- pt_sell --//

	Objs::add((new Button(0, "pt_sell", OBJ_EDIT, 0, 0, 0))
	          .set_w(60)
	          .set_h(20)
	          .set_x(30)
	          .set_y(150)
	         );


	//-- pt_buy --//

	Objs::add((new Button(0, "pt_buy", OBJ_EDIT, 0, 0, 0))
	          .set_w(60)
	          .set_h(20)
	          .set_x(190)
	          .set_y(150)
	         );


	//-- even_sell --//

	Objs::add((new Button(0, "even_sell", OBJ_EDIT, 0, 0, 0))
	          .set_text("EVEN")
	          .set_w(60)
	          .set_h(30)
	          .set_x(30)
	          .set_y(180)
	         );


	//-- even_buy --//

	Objs::add((new Button(0, "even_buy", OBJ_EDIT, 0, 0, 0))
	          .set_text("EVEN")
	          .set_w(60)
	          .set_h(30)
	          .set_x(190)
	          .set_y(180)
	         );


	//-- sl_sell --//

	Objs::add((new Button(0, "sl_sell", OBJ_EDIT, 0, 0, 0))
	          .set_w(60)
	          .set_h(30)
	          .set_x(30)
	          .set_y(225)
	          .set_readonly(false)
	         );


	//-- sl_buy --//

	Objs::add((new Button(0, "sl_buy", OBJ_EDIT, 0, 0, 0))
	          .set_w(60)
	          .set_h(30)
	          .set_x(190)
	          .set_y(225)
	          .set_readonly(false)
	         );


	//-- apply_sl_sell --//

	Objs::add((new Button(0, "apply_sl_sell", OBJ_EDIT, 0, 0, 0))
	          .set_text("apply")
	          .set_w(60)
	          .set_h(30)
	          .set_x(30)
	          .set_y(270)
	         );


	//-- apply_sl_buy --//

	Objs::add((new Button(0, "apply_sl_buy", OBJ_EDIT, 0, 0, 0))
	          .set_text("apply")
	          .set_w(60)
	          .set_h(30)
	          .set_x(190)
	          .set_y(270)
	         );


	// Button::Button(long chart_id, string name, ENUM_OBJECT type, int nwin,
	//                datetime time1, double price1, string text, long corner,
	//                int xsize, int ysize, int xdistance, int ydistance,
	//                long zorder, bool readonly
	//               );



	ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);












	Objs::add(new Button(0, "freeze", OBJ_EDIT, 0, 0, 0, "", CORNER_LEFT_UPPER,
	                     60, 20, 30, 315, 2, true));
	Objs::add(new Button(0, "leverage", OBJ_EDIT, 0, 0, 0, "", CORNER_LEFT_UPPER,
	                     60, 20, 30, 335, 2, true));

	Symbols::init();
	Symbols::print_symbols();

	ChartRedraw();

	return 0;
}  // OnInit()


////////////////////
//// OnDeinit() ////
////////////////////

void OnDeinit(const int reason)
{
	ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, false);

	ChartRedraw();

	Status::destructor();
	Objs::dlt_all();
}


// every tick, and chart event
double UI::ui(const E_FUNC FUNC, const int id, const long &lparam,
              const double &dparam, const string &sparam)
{
	Button *b;

	static bool initialized = false;
	static Trade trade();

	static Button bid(0, "bid", OBJ_EDIT, 0, 0, 0, "", CORNER_LEFT_UPPER,
	                  100, 40, 10, 355, 2, true);
	static Button ask(0, "ask", OBJ_EDIT, 0, 0, 0, "", CORNER_LEFT_UPPER,
	                  100, 40, 170, 355, 2, true);
	static Button rescue_lbl(0, "RescueLbl", OBJ_EDIT, 0, 0, 0, "Rescue",
	                         CORNER_LEFT_UPPER, 60, 20, 100, 315, 2, true);
	static CheckBox checkbox0(0, "check0", 0, 0, 0, true, 128, 256, 2);
	static CheckBox rescue_cb(0, "RescueCB", 0, 0, 0, false, 162, 317, 2);

	if (!initialized) {
		bid.set_fontsize(14);
		bid.set_fontcolor(clrWhite);
		ask.set_fontsize(14);
		ask.set_fontcolor(clrWhite);
		ObjectSetInteger(0, "check0", OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);

		initialized = true;
	}

	switch (FUNC) {
	////////////////
	//// ONTICK ////
	////////////////
	case ONTICK:
		Symbols::update();
		Price::set_prices();

		Price::update_bid_ask_spread();

		// update the bid and the ask
		bid.set_text(DoubleToString(Price::BID, Digits));
		if (Price::BID > Price::SECOND_LAST_BID)
			bid.set_bgcolor(clrCrimson);
		else if (Price::BID < Price::SECOND_LAST_BID)
			bid.set_bgcolor(clrBlue);

		ask.set_text(DoubleToString(Price::ASK, Digits));
		if (Price::ASK > Price::SECOND_LAST_ASK)
			ask.set_bgcolor(clrCrimson);
		else if (Price::ASK < Price::SECOND_LAST_ASK)
			ask.set_bgcolor(clrBlue);

		Account::update_lots_and_average();
		Account::update_points_from_average();

		if (trade.even_ok_buy())
			((Button *)Objs::get("even_buy")).set_bgcolor(clrLimeGreen);
		else
			((Button *)Objs::get("even_buy")).set_bgcolor(clrWhite);

		if (trade.even_ok_sell())
			((Button *)Objs::get("even_sell")).set_bgcolor(clrLimeGreen);
		else
			((Button *)Objs::get("even_sell")).set_bgcolor(clrWhite);

		if (rescue_cb.get_state())
			if (OrdersTotal())
				trade.even_tp();
			else  // すべてのポジションが無くなったら
				rescue_cb.toggle();  // もはや監視する意味はない．無効化する

		// ジャストこの値でも逆指値は指せた
		((Button *)Objs::get("freeze"))
		    .set_text(IntegerToString(
		        SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL)) + "pt");

		((Button *)Objs::get("leverage"))
		    .set_text(DoubleToStr(Account::get_effective_leverage(), 3));

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
			else if (sparam == "bid") {
				//trade.bid();
			} else if (sparam == "bid_more")
				trade.bid();
			else if (sparam == "bid_mid")
				trade.bid();
			else if (sparam == "bid_less")
				trade.bid();
			else if (sparam == "ask") {
				//trade.ask();
			} else if (sparam == "ask_more")
				trade.ask();
			else if (sparam == "ask_mid")
				trade.ask();
			else if (sparam == "ask_less")
				trade.ask();
			else if (sparam == "square")
				trade.square();
			else if (sparam == "close")
				trade.close();
			else if (sparam == "close_all")
				trade.close_all();
			else if (sparam == "even_buy") {
				if (trade.even_ok_buy())
					trade.even_buy();
			} else if (sparam == "even_sell") {
				if (trade.even_ok_sell())
					trade.even_sell();
			} else if (sparam == "remove_ea")
				ExpertRemove();
			else if (sparam == "apply_sl_buy") {
				b = (Button *)Objs::get("sl_buy");
				trade.set_sl_buy_by_diff(StrToInteger(b.text));
			} else if (sparam == "apply_sl_sell") {
				b = (Button *)Objs::get("sl_sell");
				trade.set_sl_sell_by_diff(StrToInteger(b.text));
			} else if (sparam == "RescueCB")
				rescue_cb.toggle();
			else if (sparam == "apply_sl") {
				// 操作対象のポジションは，必ず 0 の位置のものとした
				trade.sl_d(0,
				           StringToInteger(((Button *)Objs::get("sl")).text));
			}
			break;
		case CHARTEVENT_OBJECT_ENDEDIT:
		// sparam: Name of LabelEdit obj., in which text editing has completed
			if (sparam == "lot") {
				b = (Button *)Objs::get("lot");
				b.text_edited();
				trade.lot = StringToDouble(b.text);
				if (trade.lot < MarketInfo(Symbol(), MODE_MINLOT))
					Status::msg("invalid amount of a lot");
				else
					Status::msg("");
			} else if (sparam == "auto_sl")
				((Button *)Objs::get("auto_sl")).text_edited();
			else if (sparam == "sl_buy")
				((Button *)Objs::get("sl_buy")).text_edited();
			else if (sparam == "sl_sell")
				((Button *)Objs::get("sl_sell")).text_edited();
			break;
		}
		break;
	case ONBOOKEVENT:
		break;
	}

	return 0.0;
}


//////////////////
//// OnTick() ////
//////////////////

void OnTick()
{
	long   lparam = 0;
	double dparam = 0.0;
	string sparam = "";

	UI::ui(ONTICK, 0, lparam, dparam, sparam);
}


////////////////////////
//// OnChartEvent() ////
////////////////////////

void OnChartEvent(const int id, const long &lparam,
                  const double &dparam, const string &sparam)
{
	UI::ui(ONCHARTEVENT, id, lparam, dparam, sparam);
}
