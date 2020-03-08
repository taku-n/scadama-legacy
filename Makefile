all: scadama.ex5

scadama.ex5: scadama.mq5 account.mqh price.mqh status.mqh symbol.mqh trade.mqh ui.mqh
	-metaeditor64.exe /compile:scadama.mq5 /log:log.log
	cat log.log
	rm log.log
