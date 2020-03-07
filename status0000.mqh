#property strict

#ifndef STATUS_MQH
#define STATUS_MQH

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

Button *Status::status;

void Status::destructor()
{
	delete status;
}

void Status::msg(string msg)
{
	status.set_text(msg);
}

void Status::err(string func)
{
	status.set_text(func + " failed: " + ErrorDescription(GetLastError()));
	//status.change_text("error in " + func + ": "
	//                   + ErrorDescription(GetLastError()));
}


#endif