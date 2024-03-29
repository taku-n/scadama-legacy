#property strict

class Trade
{
	int    ticket[];  // dynamic array
	int    n;         // 保有チケット数

public:
	double lot;
	double delta;
	Trade();
	void bid();        // 成行売注文
	void ask();        // 成行買注文
	void close_all();  // 全決済
	void even();       // 同値撤退逆指値を設定
	bool even_ok();    // 同値撤退逆指値の可否
};

Trade::Trade()
{
	n = 0;
	lot = 0.01;
	delta = 0.054;
}

void Trade::bid()
{
	int t;

	ResetLastError();
	
	t = OrderSend(Symbol(), OP_SELL, lot, Bid, 10,
	                          Bid + 0.2, 0, NULL, 0, 0, Blue);
	// slippage は points

	if (t != -1)
		Status::msg("ticket number is " + IntegerToString(t));
	else
		Status::err("OrderSend()");
}

void Trade::ask()
{
	int t;

	ResetLastError();

	t = OrderSend(Symbol(), OP_BUY, lot, Ask, 10,
	                          Ask - 0.2, 0, NULL, 0, 0, Red);
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
		if (OrderSelect(0, SELECT_BY_POS)) {
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
	ResetLastError();

	if (OrderSelect(0, SELECT_BY_POS)) {
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

	if (OrderSelect(0, SELECT_BY_POS))
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
