#property strict


class Trade
{
	int    ticket[];  // dynamic array
	int    n;         // 保有チケット数

public:
	double lot;
	double delta;
	Trade();
	void bid();
	void ask();
	void close_all();
	void even();
	bool even_ok();
};

Trade::Trade()
{
	n = 0;
	lot = 0.01;
	delta = 0.054;
}

void Trade::bid()
{
	ArrayResize(ticket, ++n);
	ticket[n - 1] = OrderSend(Symbol(), OP_SELL, lot, Price::BID, 1,
	                          Price::BID - 0.2, 0, NULL, 0, 0, Blue);
}

void Trade::ask()
{
	ArrayResize(ticket, ++n);
	ticket[n - 1] = OrderSend(Symbol(), OP_BUY, lot, Price::ASK, 1,
	                          Price::ASK - 0.2, 0, NULL, 0, 0, Red);
}

void Trade::close_all()
{
	for (int i = 0; i < n; i++) {
		OrderSelect(ticket[i], SELECT_BY_TICKET);
		if (OrderType() == OP_BUY)
			OrderClose(OrderTicket(), OrderLots(), Price::BID, 1, clrBlue);
		else if (OrderType() == OP_SELL)
			OrderClose(OrderTicket(), OrderLots(), Price::ASK, 1, clrRed);
	}

	n = 0;
}

void Trade::even()
{
	OrderSelect(ticket[0], SELECT_BY_TICKET);
	OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), 0, 0,
	            CLR_NONE);
}

bool Trade::even_ok()
{
	if (OrderSelect(ticket[0], SELECT_BY_TICKET))
		if (OrderType() == OP_BUY)
			if (OrderOpenPrice() + delta < Price::BID)
				return true;
			else
				return false;
		else if (OrderType() == OP_SELL)
			if (OrderOpenPrice() - delta > Price::ASK)
				return true;
			else
				return false;
		else
			return false;
	else
		return false;
}
