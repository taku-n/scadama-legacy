#property strict


class Price
{
public:
	static double BID;
	static double ASK;
	static double SPREAD;

	static void set_bid(const double BID);
	static void set_ask(const double ASK);
};

double Price::BID    = 0.0;
double Price::ASK    = 0.0;
double Price::SPREAD = 0.0;

void Price::set_bid(const double BID)
{
	Price::BID = BID;
	Price::SPREAD = (Price::ASK - BID) * 100;
}

void Price::set_ask(const double ASK)
{
	Price::ASK = ASK;
	Price::SPREAD = (ASK - Price::BID) * 100;
}
