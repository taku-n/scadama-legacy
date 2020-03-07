#property strict

#ifndef ACCOUNT_MQH
#define ACCOUNT_MQH


class Position
{
public:
	string symbol;
	int    type;
	double lots;
	double margin_required;
};


class PositionsBySymbol
{
public:
	string symbol;
	double lots_buy;
	double lots_sell;
	double lots_total;
	double lots_net;
	double margin_required_total;
	double margin_required_net;
};


class Account
{
public:
	static double lots_buy;
	static double lots_sell;
	static double ave_buy;
	static double ave_sell;

	static void update_lots_and_average();
	static void update_points_from_average();
	static double get_effective_leverage();
};

double Account::lots_buy  = 0.0;
double Account::lots_sell = 0.0;
double Account::ave_buy   = 0.0;
double Account::ave_sell  = 0.0;

void Account::update_lots_and_average()
{
	lots_buy = lots_sell = 0.0;
	ave_buy  = ave_sell  = 0.0;

	for (int i = 0; i < OrdersTotal(); i++) {
		OrderSelect(i, SELECT_BY_POS);
		if (OrderSymbol() == _Symbol) {
			if (OrderType() == OP_BUY) {
				ave_buy = (ave_buy * lots_buy + OrderOpenPrice() * OrderLots())
				          / (lots_buy + OrderLots());
				lots_buy += OrderLots();
			} else if (OrderType() == OP_SELL) {
				ave_sell = (ave_sell * lots_sell
				            + OrderOpenPrice() * OrderLots()
				           ) / (lots_sell + OrderLots());
				lots_sell += OrderLots();
			}
		}
	}

	((Button *)Objs::get("lot_buy")).set_text(DoubleToStr(Account::lots_buy, 2));
	((Button *)Objs::get("lot_sell")).set_text(DoubleToStr(Account::lots_sell, 2));
	((Button *)Objs::get("ave_buy"))
	    .set_text(DoubleToStr(Account::ave_buy, Digits));
	((Button *)Objs::get("ave_sell"))
	    .set_text(DoubleToStr(Account::ave_sell, Digits));
}

void Account::update_points_from_average()
{
	string str;

	if (ave_buy == 0.0)
		str = "";
	else
		str = DoubleToStr((Bid - ave_buy) / Point, 0);
	((Button *)Objs::get("pt_buy")).set_text(str);

	if (ave_sell == 0.0)
		str = "";
	else
		str = DoubleToStr((ave_sell - Ask) / Point, 0);
	((Button *)Objs::get("pt_sell")).set_text(str);
}

double Account::get_effective_leverage()
{
	Position p[];
	ArrayResize(p, SymbolsTotal(true));

	PositionsBySymbol pbs[];

	int    number_of_symbols;
	bool   is_found;
	double amount_total = 0.0;
	double leverage;
	double maybe_effective_leverage;
	double effective_leverage;

	// get the amount of a lot, usually 100000.0
	double lot_size        = MarketInfo(_Symbol, MODE_LOTSIZE);

	double margin_required = MarketInfo(_Symbol, MODE_MARGINREQUIRED);

	string s_short_currency = SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT);

	double usd_jpy = MarketInfo("USDJPY", MODE_BID);

	// get the margin level and convert percentage to raw
	double margin_level = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL) / 100.0;

	// a leverage of a CFD is probably different from the leverage of the account
	// calculate the leverage 
	if (s_short_currency == "JPY")
		leverage = lot_size * Ask / margin_required;
	else if (s_short_currency == "USD")
		leverage = lot_size * Ask * usd_jpy / margin_required;
	else
		leverage = AccountLeverage();

	if (margin_level != 0.0)
		effective_leverage = leverage / margin_level;
	else
		effective_leverage = 0.0;

	// get informations of positions
	for (int i = 0; i < OrdersTotal(); i++) {
		OrderSelect(i, SELECT_BY_POS);
		p[i].symbol          = OrderSymbol();
		p[i].type            = OrderType();
		p[i].lots            = OrderLots();
		p[i].margin_required = StrToDouble(OrderComment());
	}

	// divide informations
	for (int i = 0; i < OrdersTotal(); i++) {
		number_of_symbols = ArraySize(pbs);
		is_found = false;
		for (int j = 0; j < number_of_symbols; j++) {
			if (pbs[j].symbol == p[i].symbol) {
				if (p[i].type == OP_BUY)
					pbs[j].lots_buy  += p[i].lots;
				else if (p[i].type == OP_SELL)
					pbs[j].lots_sell += p[i].lots;
				pbs[j].margin_required_total += p[i].margin_required;
				is_found = true;
				break;
			}
		}

		if (!is_found) {
			ArrayResize(pbs, number_of_symbols + 1);
			pbs[number_of_symbols].symbol = p[i].symbol;
			if (p[i].type == OP_BUY) {
				pbs[number_of_symbols].lots_buy  = p[i].lots;
				pbs[number_of_symbols].lots_sell = 0.0;
			} else if (p[i].type == OP_SELL) {
				pbs[number_of_symbols].lots_buy  = 0.0;
				pbs[number_of_symbols].lots_sell = p[i].lots;
			}
			pbs[number_of_symbols].margin_required_total = p[i].margin_required;
		}
	}

	// calculate net lots and net margins required
	for (int i = 0; i < ArraySize(pbs); i++) {
		if (pbs[i].lots_total = pbs[i].lots_buy + pbs[i].lots_sell) {

			if (pbs[i].lots_buy >= pbs[i].lots_sell)
				pbs[i].lots_net = pbs[i].lots_buy;
			else
				pbs[i].lots_net = pbs[i].lots_sell;

			pbs[i].margin_required_net = pbs[i].margin_required_total
		                                 * (pbs[i].lots_net / pbs[i].lots_total);
		} else {
			pbs[i].lots_net            = 0.0;
			pbs[i].margin_required_net = 0.0;
		}
	}

	for (int i = 0; i < ArraySize(pbs); i++) {
		amount_total += pbs[i].margin_required_net
		                * Symbols::get_leverage(pbs[i].symbol);
	}

	maybe_effective_leverage = amount_total / AccountEquity();

	/*
	for (int i = 0; i < ArraySize(pbs); i++) {
		Print(i, ", ", pbs[i].symbol, ": ", pbs[i].lots_buy, ", ",
		      pbs[i].lots_sell, ", ", pbs[i].margin_required_total, ", ",
		      "net: ", pbs[i].lots_net, ", ", pbs[i].margin_required_net
		     );
	}
	*/

	return maybe_effective_leverage;
}


#endif