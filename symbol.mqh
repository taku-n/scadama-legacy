#property strict

#ifndef SYMBOLS_MQH
#define SYMBOLS_MQH


// has pair informations
struct sym
{
	string name;
	string currency_long;   // if EURUSD, it is EUR
	string currency_short;  // if EURUSD, it is USD
	double lot_size;        // usually 100000.0
	double leverage;
};


class Symbols
{
public:
	static sym s[];
	static int number_of_symbols;

	static bool has_decimal_point;
	static int  int_part;

	// call this on the OnInit() function
	static void init()
	{
		if (Digits)
			has_decimal_point = true;
	}
	
	// call this on the every tick
	static void update()
	{
		if (Digits) {
			int_part = StringLen(DoubleToStr(Bid, 0));
		} else
			int_part = StringLen(DoubleToStr(Bid, Digits)) - Digits - 1;

		if (SymbolsTotal(true) != number_of_symbols) {
			update_symbols();
			number_of_symbols = SymbolsTotal(true);
			//print_symbols();
		}
	}

	// get a pair name
	static string get_name(const string LONG, const string SHORT);

	// updates symbol informations
	static void update_symbols();

	static double get_leverage(string symbol)
	{
		for (int i = 0; i < ArraySize(s); i++) {
			if (s[i].name == symbol)
				return s[i].leverage;
		}

		return AccountLeverage();
	}

	static void print_symbols()
	{/*
		for (int i = 0; i < SymbolsTotal(true); i++)
			PrintFormat("%6s: %s, %.3f, %.3f",
			            s[i].name, s[i].currency_short, s[i].lot_size, s[i].leverage
			           );
	*/}
};

sym  Symbols::s[];
int  Symbols::number_of_symbols = 0;
bool Symbols::has_decimal_point = false;
int  Symbols::int_part          = 0;

string Symbols::get_name(const string LONG, const string SHORT)
{
	string name;  // a pair name

	// looking for a pair matching
	for (int i = 0; i < SymbolsTotal(false); i++) {
		name = SymbolName(i, false);

		if (SymbolInfoString(name, SYMBOL_CURRENCY_BASE) == LONG)
			if (SymbolInfoString(name, SYMBOL_CURRENCY_PROFIT) == SHORT)
				return name;
	}

	return NULL;
}

void Symbols::update_symbols()
{
	SymbolSelect(get_name("USD", "JPY"), true);
	SymbolSelect(get_name("USD", "CHF"), true);
	SymbolSelect(get_name("CHF", "JPY"), true);

	ArrayResize(s, SymbolsTotal(true));

	// initialize informations
	for (int i = 0; i < SymbolsTotal(true); i++) {
		s[i].name           = SymbolName(i, true);
		s[i].currency_long  = SymbolInfoString(s[i].name, SYMBOL_CURRENCY_BASE);
		s[i].currency_short = SymbolInfoString(s[i].name, SYMBOL_CURRENCY_PROFIT);
		s[i].lot_size       = MarketInfo(s[i].name, MODE_LOTSIZE);

		if (AccountCurrency() == "USD") {

			if (s[i].currency_short == "USD")
				s[i].leverage = MarketInfo(s[i].name, MODE_ASK) * s[i].lot_size
				                / MarketInfo(s[i].name, MODE_MARGINREQUIRED);
			else if (s[i].currency_short == "JPY") {
				Print("calculating: ", s[i].name);
				s[i].leverage = MarketInfo(s[i].name, MODE_ASK) * s[i].lot_size
				                / MarketInfo(get_name("USD", "JPY"), MODE_ASK)
				                / MarketInfo(s[i].name, MODE_MARGINREQUIRED);
				Print("leverage: ", s[i].leverage);
				Print("ask: ", MarketInfo(s[i].name, MODE_ASK),
				      ", lotsize: ", s[i].lot_size,
				      ", bid_of_USDJPY: ",
				      MarketInfo(get_name("USD", "JPY"), MODE_BID),
				      ", margin_required: ",
				      MarketInfo(s[i].name, MODE_MARGINREQUIRED)
				     );
				Print("get_name(): ", get_name("USD", "JPY"));
			} else if (s[i].currency_short == "CHF")
				s[i].leverage = MarketInfo(s[i].name, MODE_ASK) * s[i].lot_size
				                / MarketInfo(get_name("USD", "CHF"), MODE_ASK)
				                / MarketInfo(s[i].name, MODE_MARGINREQUIRED);
			else
				s[i].leverage = AccountLeverage();

		} else if (AccountCurrency() == "JPY") {

			if (s[i].currency_short == "USD")
				s[i].leverage = MarketInfo(s[i].name, MODE_ASK) * s[i].lot_size
				                * MarketInfo(get_name("USD", "JPY"), MODE_BID)
				                / MarketInfo(s[i].name, MODE_MARGINREQUIRED);
			else if (s[i].currency_short == "JPY")
				s[i].leverage = MarketInfo(s[i].name, MODE_ASK) * s[i].lot_size
				                / MarketInfo(s[i].name, MODE_MARGINREQUIRED);
			else if (s[i].currency_short == "CHF")
				s[i].leverage = MarketInfo(s[i].name, MODE_ASK) * s[i].lot_size
				                * MarketInfo(get_name("CHF", "JPY"), MODE_BID)
				                / MarketInfo(s[i].name, MODE_MARGINREQUIRED);
			else
				s[i].leverage = AccountLeverage();

		} else {

			s[i].leverage = AccountLeverage();

		}
	}

	for (int i = 0; i < SymbolsTotal(true); i++)
		Print(s[i].name, ": ", s[i].currency_short, ", ", s[i].lot_size,
		      ", ", s[i].leverage
		     );
}


#endif