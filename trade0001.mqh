#property strict

class Trade
{
	int    ticket[];  // dynamic array
	int    n;         // 保有チケット数
	double margin;    // 指値と逆指値で現在価格からいくら離さないといけないか

public:
	double lot;
	double delta;
	Trade();
	void bid();                 // 成行売注文
	void ask();                 // 成行買注文
	void close_all();           // 全決済
	void even();                // 同値撤退逆指値を設定
	bool even_ok();             // 同値撤退逆指値の可否
	void even_tp();             // 同値撤退指値の設定を試行

	// 逆指値を設定
	// i: 操作対象ポジションの位置, sl: 設定したい逆指値のレート
	void sl(int i, double sl);

	// 逆指値を差で設定
	// i: 操作対象ポジションの位置, d: 建玉値からの差 (単位は pt)
	void sl_d(int i, int d);
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
	              Bid + StringToInteger(b.text) * Point, 0, NULL, 0, 0, Blue);
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
	              Ask - StringToInteger(b.text) * Point, 0, NULL, 0, 0, Red);
	// slippage は points

	if (t != -1)
		Status::msg("ticket number is " + IntegerToString(t));
	else
		Status::err("OrderSend()");
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
				if (!OrderClose(OrderTicket(), OrderLots(), Bid, 10, clrBlue))
					Status::err("OrderClose()");
			} else if (OrderType() == OP_SELL)
				if (!OrderClose(OrderTicket(), OrderLots(), Ask, 10, clrRed))
					Status::err("OrderClose()");
		} else
			Status::err("OrderSelect()");
	}
}

void Trade::even()
{
	int total = OrdersTotal();

	ResetLastError();

	if (OrderSelect(total - 1, SELECT_BY_POS)) {
		if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), 0,
		    0))
			Status::err("OrderModify()");
	} else
		Status::err("OrderSelect()");
}

bool Trade::even_ok()
{
	double margin = MarketInfo(Symbol(), MODE_STOPLEVEL);
	double pt     = MarketInfo(Symbol(), MODE_POINT);      // 1pt = ?\, ?$
	int    total  = OrdersTotal();

	if (OrderSelect(total - 1, SELECT_BY_POS))
		if (OrderType() == OP_BUY)
			if (OrderOpenPrice() + margin * pt <= Bid)
				return true;
			else
				return false;
		else if (OrderType() == OP_SELL)
			if (OrderOpenPrice() - margin * pt >= Ask)
				return true;
			else
				return false;
		else
			return false;
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
		if (!OrderModify(OrderTicket(), OrderOpenPrice(), sl, 0.0, 0))
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
			sl(i, OrderOpenPrice() - (double)d * Point);
		else if (OrderType() == OP_SELL)
			sl(i, OrderOpenPrice() + (double)d * Point);
	} else
		Status::err(__FUNCTION__);
}