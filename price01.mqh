#property strict


class Price
{
public:
	static double BID;
	static double ASK;
	static double SPREAD;
	static double SECOND_LAST_BID;
	static double SECOND_LAST_ASK;
	static double SECOND_LAST_SPREAD;

	static void set_bid(const double BID);
	static void set_ask(const double ASK);
	static void set_spread();
};

double Price::BID                = 0.0;
double Price::ASK                = 0.0;
double Price::SPREAD             = 0.0;
double Price::SECOND_LAST_BID    = 0.0;
double Price::SECOND_LAST_ASK    = 0.0;
double Price::SECOND_LAST_SPREAD = 0.0;

void Price::set_bid(const double BID)
{
	Price::SECOND_LAST_BID = Price::BID;
	Price::BID = BID;
}

void Price::set_ask(const double ASK)
{
	Price::SECOND_LAST_ASK = Price::ASK;
	Price::ASK = ASK;
}

void Price::set_spread()
{
	Price::SECOND_LAST_SPREAD = Price::SPREAD;
	Price::SPREAD = (Price::ASK - Price::BID) * 100;
}
