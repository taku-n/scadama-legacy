#property strict

#include <stderror.mqh>
#include <stdlib.mqh>


class Status
{
public:
	static Button &status;  // どうやったら他のクラスが使える?
	static void msg(string msg);
	static void err();
};

void Status::msg(string msg)
{
	status.change_text(msg);
}

void Status::err()
{
	
}
