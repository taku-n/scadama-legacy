#property strict

#include <stderror.mqh>
#include <stdlib.mqh>


class Status
{
public:
	static Button *status;

	static void destructor();
	static void msg(string msg);
	static void err(string func);
};

void Status::destructor()
{
	delete status;
}

void Status::msg(string msg)
{
	status.change_text(msg);
}

void Status::err(string func)
{
	status.change_text(func + " failed: " + ErrorDescription(GetLastError()));
	//status.change_text("error in " + func + ": "
	//                   + ErrorDescription(GetLastError()));
}
