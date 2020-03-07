#property strict

#ifndef PRICE_MQH
#define PRICE_MQH


// this class depends on the Symbols class
// use this class after you call the function Symbols::init() and Symbols::update()
class Price
{
public:
	static double BID;
	static double ASK;
	static double SPREAD;
	static double SECOND_LAST_BID;
	static double SECOND_LAST_ASK;
	static double SECOND_LAST_SPREAD;
	static string BID_MORE;
	static string BID_MID;
	static string BID_LESS;
	static string ASK_MORE;
	static string ASK_MID;
	static string ASK_LESS;

	static void   set_bid(const double BID);
	static void   set_ask(const double ASK);
	static void   set_spread();
	static double ave();

	// refresh the price informations
	// should run this on every tick
	static void set_prices()
	{
		string s_bid = DoubleToStr(Bid, Digits);
		string s_ask = DoubleToStr(Ask, Digits);

		// EUR/USD, GBP/USD, AUD/USD, ...
		if (SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT) == "USD") {
			if (SymbolInfoString(_Symbol, SYMBOL_CURRENCY_BASE) == "XAU") {
				if (Symbols::has_decimal_point) {
					BID_MORE = StringSubstr(s_bid, 0, Symbols::int_part - 2);
					ASK_MORE = StringSubstr(s_ask, 0, Symbols::int_part - 2);
					BID_MID  = StringSubstr(s_bid, Symbols::int_part - 2, 2);
					ASK_MID  = StringSubstr(s_ask, Symbols::int_part - 2, 2);
					BID_LESS = StringSubstr(s_bid, Symbols::int_part);
					ASK_LESS = StringSubstr(s_ask, Symbols::int_part);
				}
			} else if (SymbolInfoString(_Symbol, SYMBOL_CURRENCY_BASE) == "XAG") {
				if (Symbols::has_decimal_point) {
					BID_MORE = StringSubstr(s_bid, 0, Symbols::int_part + 1);
					ASK_MORE = StringSubstr(s_ask, 0, Symbols::int_part + 1);
					BID_MID  = StringSubstr(s_bid, Symbols::int_part + 1);
					ASK_MID  = StringSubstr(s_ask, Symbols::int_part + 1);
				}
			} else {
				// if it has the decimal point
				if (Symbols::has_decimal_point) {
					BID_MORE = StringSubstr(s_bid, 0, Symbols::int_part + 3);
					ASK_MORE = StringSubstr(s_ask, 0, Symbols::int_part + 3);
					BID_MID  = StringSubstr(s_bid, Symbols::int_part + 3, 2);
					ASK_MID  = StringSubstr(s_ask, Symbols::int_part + 3, 2);
					BID_LESS = StringSubstr(s_bid,
					                        Symbols::int_part + 5,
					                        StringLen(_Symbol)
					                        - Symbols::int_part + 5
				                           );
					ASK_LESS = StringSubstr(s_ask,
				   	                     Symbols::int_part + 5,
				   	                     StringLen(_Symbol) - Symbols::int_part + 5
   				                           );
				}
			}
		}

		// USD/JPY, EUR/JPY, GBP/JPY, ...
		if (SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT) == "JPY") {
			// if it has the decimal point
			if (Symbols::has_decimal_point) {
				BID_MORE = StringSubstr(s_bid, 0, Symbols::int_part + 1);
				ASK_MORE = StringSubstr(s_ask, 0, Symbols::int_part + 1);
				BID_MID  = StringSubstr(s_bid, Symbols::int_part + 1, 2);
				ASK_MID  = StringSubstr(s_ask, Symbols::int_part + 1, 2);
				BID_LESS = StringSubstr(s_bid,
				                        Symbols::int_part + 3,
				                        StringLen(_Symbol) - Symbols::int_part + 3
				                       );
				ASK_LESS = StringSubstr(s_ask,
				                        Symbols::int_part + 3,
				                        StringLen(_Symbol) - Symbols::int_part + 3
				                       );
			}
		}

		set_bid(Bid);
		set_ask(Ask);
		set_spread();
	}

	// refresh the price informations of any symbols
	// should run this on every tick
	static void set_prices(string symbol)
	{
		// under construction

		SymbolInfoDouble(symbol, SYMBOL_BID);
		SymbolInfoDouble(symbol, SYMBOL_ASK);
	}

	static void update_bid_ask_spread();
	static void update_bid();
	static void update_ask();
	static void update_spread();
	static void set_bid_color(color clr);
	static void set_ask_color(color clr);
	static void set_spread_color(color clr);
};

double Price::BID                = 0.0;
double Price::ASK                = 0.0;
double Price::SPREAD             = 0.0;
double Price::SECOND_LAST_BID    = 0.0;
double Price::SECOND_LAST_ASK    = 0.0;
double Price::SECOND_LAST_SPREAD = 0.0;
string Price::BID_MORE           = "";
string Price::BID_MID            = "";
string Price::BID_LESS           = "";
string Price::ASK_MORE           = "";
string Price::ASK_MID            = "";
string Price::ASK_LESS           = "";

void Price::set_bid(const double BID)
{
	SECOND_LAST_BID = Price::BID;
	Price::BID = BID;
}

void Price::set_ask(const double ASK)
{
	SECOND_LAST_ASK = Price::ASK;
	Price::ASK = ASK;
}

void Price::set_spread()
{
	SECOND_LAST_SPREAD = SPREAD;
	SPREAD = (ASK - BID) / Point;
}

double Price::ave()
{
	double ave;
	double lots;

	for (int i = 0; i < OrdersTotal(); i++) {
		OrderSelect(i, SELECT_BY_POS);
		if (i == 0) {
			ave  = OrderOpenPrice();
			lots = OrderLots();
		} else {
			ave = (ave * lots + OrderOpenPrice() * OrderLots())
			          / (lots + OrderLots());
			lots += OrderLots();
		}
	}

	return ave;
}

void Price::update_bid_ask_spread()
{
	update_bid();
	update_ask();
	update_spread();
}

void Price::update_bid()
{
	((Button *)Objs::get("bid_more")).set_text(BID_MORE);
	((Button *)Objs::get("bid_mid")).set_text(BID_MID);
	((Button *)Objs::get("bid_less")).set_text(BID_LESS);

	if (BID > SECOND_LAST_BID) {
		set_bid_color(clrCrimson);
	} else if (BID < SECOND_LAST_BID) {
		set_bid_color(clrBlue);
	}
}

void Price::update_ask()
{
	((Button *)Objs::get("ask_more")).set_text(ASK_MORE);
	((Button *)Objs::get("ask_mid")).set_text(ASK_MID);
	((Button *)Objs::get("ask_less")).set_text(ASK_LESS);

	if (ASK > SECOND_LAST_ASK) {
		set_ask_color(clrCrimson);
	} else if (ASK < SECOND_LAST_ASK) {
		set_ask_color(clrBlue);
	}
}

void Price::update_spread()
{
	((Button *)Objs::get("spread")).set_text(DoubleToString(SPREAD, 0));

	if (SPREAD > SECOND_LAST_SPREAD) {
		set_spread_color(clrCrimson);
	} else if (SPREAD < SECOND_LAST_SPREAD) {
		set_spread_color(clrBlue);
	}
}

void Price::set_bid_color(color clr)
{
	((Button *)Objs::get("bid_more")).set_bgcolor(clr)
	                                 .set_border_color(clr);
	((Button *)Objs::get("bid_mid")).set_bgcolor(clr)
	                                .set_border_color(clr);
	((Button *)Objs::get("bid_less")).set_bgcolor(clr)
	                                 .set_border_color(clr);
}

void Price::set_ask_color(color clr)
{
	((Button *)Objs::get("ask_more")).set_bgcolor(clr)
	                                 .set_border_color(clr);
	((Button *)Objs::get("ask_mid")).set_bgcolor(clr)
	                                .set_border_color(clr);
	((Button *)Objs::get("ask_less")).set_bgcolor(clr)
	                                 .set_border_color(clr);
}

void Price::set_spread_color(color clr)
{
	((Button *)Objs::get("spread")).set_bgcolor(clr)
	                               .set_border_color(clr);
}

#endif