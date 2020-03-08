#property strict

#ifndef TRADE_MQH
#define TRADE_MQH

///////////////////////////////////////////////////////////
// First of all, you should check the Take Profit Margin //
// and the Stop Loss Margin of your broker               //
// because it can cause a trouble in debug.              //
///////////////////////////////////////////////////////////

// int OrderSend(string symbol, int cmd, double volume, double price,
//               int slippage, double stoploss, double takeprofit,
//               string comment = NULL, int magic = 0, datetime expiration = 0,
//               color arrow_color = clrNONE);


class Trade
{
	int    ticket[];  // dynamic array
	int    n;         // 保有チケット数
	double margin;    // 指値と逆指値で現在価格からいくら離さないといけないか

public:
	double lot;
	double delta;
	Trade();
	void bid();           // 成行売注文
	void ask();           // 成行買注文
	bool square();
	void close();         // 全決済
	void close_all();     // 全通貨全決済 including CFDs
	void even_buy();      // 同値撤退逆指値を設定
	void even_sell();
	bool even_ok_buy();   // 同値撤退逆指値の可否
	bool even_ok_sell();
	void even_tp();       // 同値撤退指値の設定を試行

	// 逆指値を設定
	// i: 操作対象ポジションの位置, sl: 設定したい逆指値のレート
	void sl(int i, double sl);

	// 逆指値を差で設定
	// i: 操作対象ポジションの位置, d: 建玉値からの差 (単位は pt)
	void sl_d(int i, int d);

	bool set_sl_buy(const double PRICE);
	bool set_sl_sell(const double PRICE);
	bool set_sl_buy_by_diff(const int POINTS);
	bool set_sl_sell_by_diff(const int POINTS);
};

Trade::Trade()
{
	n = 0;
	lot = 0.01;
	delta = 0.054;
	margin = MarketInfo(Symbol(), MODE_STOPLEVEL)
	         * MarketInfo(Symbol(), MODE_POINT);
}

void Trade::bid()
{
	int t;
	Button *b = (Button *)Objs::get("auto_sl");

	ResetLastError();

	t = OrderSend(Symbol(), OP_SELL, lot, Bid, 10,
	              Bid - StringToInteger(b.text) * Point, 0,
	              DoubleToStr(MarketInfo(_Symbol, MODE_MARGINREQUIRED) * lot, 6),
	              0, 0, Blue
	             );
	// slippage は points

	if (t != -1)
		Status::msg("ticket number is " + IntegerToString(t));
	else
		Status::err("OrderSend()");
}

void Trade::ask()
{
	int t;
	Button *b = (Button *)Objs::get("auto_sl");

	ResetLastError();

	t = OrderSend(Symbol(), OP_BUY, lot, Ask, 10,
	              Ask + StringToInteger(b.text) * Point, 0,
	              DoubleToStr(MarketInfo(_Symbol, MODE_MARGINREQUIRED) * lot, 6),
	              0, 0, Red
	             );
	// slippage は points

	if (t != -1)
		Status::msg("ticket number is " + IntegerToString(t));
	else
		Status::err("OrderSend()");
}

bool Trade::square()
{
	Print("-------- square() begins --------");

	int ticket_buy  = 0;
	int ticket_sell = 0;

	ResetLastError();

	for (int i = OrdersTotal() - 1; i >= 0; i--) {
		if (OrderSelect(i, SELECT_BY_POS)) {
			if (OrderSymbol() == _Symbol) {
				if (OrderType() == OP_BUY) {
					// It causes a problem if the ticket is really No. 0.
					if (!ticket_buy) {
						ticket_buy = OrderTicket();
					}
				} else if (OrderType() == OP_SELL) {
					if (!ticket_sell) {
						ticket_sell = OrderTicket();
					}
				}
			}
		} else {
			Status::err("OrderSelect()");
			return false;
		}
	}

	Print("ticket_buy: ", ticket_buy, ", ticket_sell: ", ticket_sell);

	if (ticket_buy && ticket_sell) {
		if (!OrderCloseBy(ticket_buy, ticket_sell)) {
			Status::err("OrderCloseBy()");
			return false;
		}

		square();
	}

	Print("-------- square() ends --------");

	return true;
}

void Trade::close()
{
	const int TOTAL = OrdersTotal();

	ResetLastError();

	for (int i = 0; i < TOTAL; i++)
		if (OrderSelect(TOTAL - i - 1, SELECT_BY_POS)) {  // FILO
			if (OrderSymbol() == _Symbol)
				if (OrderType() == OP_BUY) {
					if (!OrderClose(OrderTicket(), OrderLots(), Bid, 10, clrBlue))
						Status::err("OrderClose()");
				} else if (OrderType() == OP_SELL) {
					if (!OrderClose(OrderTicket(), OrderLots(), Ask, 10, clrRed))
						Status::err("OrderClose()");
				}
		} else
			Status::err("OrderSelect()");
}

void Trade::close_all()
{
	int total = OrdersTotal();

	ResetLastError();

	for (int i = 0; i < total; i++) {
		if (OrderSelect(total - i - 1, SELECT_BY_POS)) {  // FILO
		//if (OrderSelect(0, SELECT_BY_POS)) {
		// FIFO の場合は，最初の引数は 0 でいい
		// 決済されるたびに詰まっていくから
			if (OrderType() == OP_BUY) {
				// Using the predefined Bid, チャートの通貨以外は決済できなくなってしまう
				if (!OrderClose(OrderTicket(), OrderLots(),
				                MarketInfo(OrderSymbol(), MODE_BID), 10, clrBlue
				               )
				   )
					Status::err("OrderClose()");
			} else if (OrderType() == OP_SELL)
				if (!OrderClose(OrderTicket(), OrderLots(),
				                MarketInfo(OrderSymbol(), MODE_ASK), 10, clrRed
				               )
				   )
					Status::err("OrderClose()");
		} else
			Status::err("OrderSelect()");
	}
}

// Execute this function
// after you check it can be run using by Trade::even_ok_buy()
// because this does not check the stop loss margin
void Trade::even_buy()
{
	Print("---- Trade::even_buy() ----");

	const int TOTAL = OrdersTotal();
	const double PT = MarketInfo(_Symbol, MODE_POINT);  // 1pt = ?JPY, ?USD

	ResetLastError();

	for (int i = 0; i < TOTAL; i++) {
		if (OrderSelect(i, SELECT_BY_POS)) {
			if (OrderSymbol() == _Symbol) {
				if (OrderType() == OP_BUY) {
					if (!OrderModify(OrderTicket(), OrderOpenPrice(),
					                 Account::ave_buy + 10.0 * PT, 0, 0
					                )
					   ) {
						Status::err("OrderModify()");
					}
				}
			}
		} else
			Status::err("OrderSelect()");
	}
}

// Execute this function after you check Trade::even_ok_sell()
// because this does not check the stop loss margin
void Trade::even_sell()
{
	Print("---- Trade::even_sell() ----");

	const int TOTAL = OrdersTotal();
	const double PT = MarketInfo(_Symbol, MODE_POINT);  // 1pt = ?JPY, ?USD

	ResetLastError();

	for (int i = 0; i < TOTAL; i++) {
		if (OrderSelect(i, SELECT_BY_POS)) {
			if (OrderSymbol() == _Symbol) {
				if (OrderType() == OP_SELL) {
					if (!OrderModify(OrderTicket(), OrderOpenPrice(),
					                 Account::ave_sell - 10.0 * PT, 0, 0
					                )
					   ) {
						Status::err("OrderModify()");
					}
				}
			}
		} else
			Status::err("OrderSelect()");
	}
}

bool Trade::even_ok_buy()
{
	double margin = MarketInfo(_Symbol, MODE_STOPLEVEL);
	double pt     = MarketInfo(_Symbol, MODE_POINT);  // 1pt = ?JPY, ?USD

	margin = margin + 10.0;

	if (Account::ave_buy != 0.0 && Account::ave_buy + margin * pt <= Bid)
		return true;
	else
		return false;
}

bool Trade::even_ok_sell()
{
	double margin = MarketInfo(_Symbol, MODE_STOPLEVEL);
	double pt     = MarketInfo(_Symbol, MODE_POINT);  // 1pt = ?JPY, ?USD

	margin = margin + 10.0;

	if (Ask <= Account::ave_sell - margin * pt)
		return true;
	else
		return false;
}

void Trade::even_tp()
{
	double tp;
	int    oti;
	int    oty; 
	double oop;
	double otp;
	double osl;
	int    total = OrdersTotal();

	ResetLastError();

	if (OrderSelect(total - 1, SELECT_BY_POS)) {
	// 最初の引数は total - 1 だが，決済されるたびに total は減るので
	// 結局すべてのポジを指す
	//if (OrderSelect(0, SELECT_BY_POS)) {
	// 最初の引数は 0 だが，決済されるたびに詰まっていくので
	// 結局すべてのポジを指しているはず
		oti = OrderTicket();
		oty = OrderType();        // 買と売
		oop = OrderOpenPrice();   // ポジション価格
		otp = OrderTakeProfit();  // 現在の指値
		osl = OrderStopLoss();    // 現在の逆指値

		if (otp == oop)  // 同値撤退指値が達成されているなら
			return;
	} else {
		Status::err(__FUNCTION__);
		return;
	}

	if (oty == OP_BUY) {
		if (Bid + margin < otp || otp == 0.0) {  // 今の指値より小さくできるなら
			if (Bid + margin <= oop)
				tp = oop;
			else
				tp = Bid + margin;
			if (!OrderModify(oti, oop, osl, tp, 0))
				Status::err(__FUNCTION__);
		}
	} else if (oty == OP_SELL)
		if (Ask - margin > otp) {
			if (Ask - margin >= oop)
				tp = oop;
			else
				tp = Ask - margin;
			if (!OrderModify(oti, oop, osl, tp, 0))
				Status::err(__FUNCTION__);
		}
}

void Trade::sl(int i, double sl)
{
	Print("Trade::sl(", i, ", ", sl, ")");

	ResetLastError();

	if (OrderSelect(i, SELECT_BY_POS)) {
		// printing for debug
		if (OrderType() == OP_BUY)
			Print("OrderModify(", OrderTicket(), ", ", OrderOpenPrice(), ", ",
			      sl, ", 0.0, 0) (",
			      DoubleToStr(OrderOpenPrice() - sl, Digits), ", ",
			      DoubleToStr(Bid - sl, Digits), ")");
		else if (OrderType() == OP_SELL)
			Print("OrderModify(", OrderTicket(), ", ", OrderOpenPrice(), ", ",
			      sl, ", 0.0, 0) (",
			      DoubleToStr(sl - OrderOpenPrice(), Digits), ", ",
			      DoubleToStr(sl - Ask, Digits), ")");

		if (OrderModify(OrderTicket(), OrderOpenPrice(), sl, 0.0, 0))
			Status::msg("setting stoploss succeeded: "
			             + DoubleToStr(sl, Digits));
		else
			Status::err(__FUNCTION__);
	} else
		Status::err(__FUNCTION__);
}

void Trade::sl_d(int i, int d)
{
	Print("Trade::sl_d(", i, ", ", d, ")");

	ResetLastError();

	if (OrderSelect(i, SELECT_BY_POS)) {
		if (OrderType() == OP_BUY)
			sl(i, OrderOpenPrice() + (double)d * Point);
		else if (OrderType() == OP_SELL)
			sl(i, OrderOpenPrice() - (double)d * Point);
	} else
		Status::err(__FUNCTION__);
}

bool Trade::set_sl_buy(const double PRICE)
{
	return true;
}

bool Trade::set_sl_sell(const double PRICE)
{
	return true;
}

bool Trade::set_sl_buy_by_diff(const int POINTS)
{
	Print("-------- set_sl_buy_by_diff(", POINTS, ") begins --------");

	ResetLastError();

	for (int i = 0; i < OrdersTotal(); i++) {
		if (OrderSelect(i, SELECT_BY_POS)) {
			if (OrderSymbol() == _Symbol) {
				if (OrderType() == OP_BUY) {
					sl_d(i, POINTS);
				}
			}
		} else {
			Status::err("OrderSelect()");
		}
	}

	Print("-------- set_sl_buy_by_diff(", POINTS, ") ends --------");

	return true;
}

bool Trade::set_sl_sell_by_diff(const int POINTS)
{
	ResetLastError();

	for (int i = 0; i < OrdersTotal(); i++) {
		if (OrderSelect(i, SELECT_BY_POS)) {
			if (OrderSymbol() == _Symbol) {
				if (OrderType() == OP_SELL) {
					sl_d(i, POINTS);
				}
			}
		} else {
			Status::err("OrderSelect()");
		}
	}

	return true;
}

#endif