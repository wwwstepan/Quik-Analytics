fLog = nil
stopped = false

function myLog(str)
	if fLog ~= nil then
		fLog:write(os.date() .. " ".. str .. "\n")
	end
end

function OnInit(path)
	fLog = io.open("vol_and_ticker.log", "w+t")
	myLog("in OnInit. script path = " .. path)
end

function OnStop(signal)
	stopped = true
end

function OnClose()
	fLog:close()
end

function main( ... )
	mainT = AllocTable()
	
	AddColumn(mainT,1,"price",true,QTABLE_STRING_TYPE,15)
	AddColumn(mainT,2,"vol",true,QTABLE_STRING_TYPE,15)
	
	CreateWindow(mainT)
	SetWindowCaption (mainT,"RI vol")
	
	tblRIVol = {}
	tblBRVol = {}
	
	nTrade = 1 --getNumberOf("ALL_TRADES")
	
	while not stopped do
		if isConnected() then
			sleep(500)
			totalTrades = getNumberOf("ALL_TRADES")
			
			if nTrade < totalTrades then
				
				numAdd = 0
			
				while nTrade < totalTrades do
					itTrade = getItem("ALL_TRADES", nTrade)
					
					secCode = itTrade["sec_code"]

					if secCode == "RIM0" then
						
						pr = itTrade["price"]
						qty = itTrade["qty"]
						--op = itTrade["OPERATION"]
						--tm = itTrade["TIME"]
						
						oldQty = tblRIVol[round50txt6(pr)]
						if oldQty == nil then
							oldQty = 0
						end
						tblRIVol[round50txt6(pr)] = oldQty + qty
						numAdd = numAdd + 1
					end
					
					nTrade = nTrade + 1
				end
				
				if numAdd>0 then
				
					Clear(mainT)
					
					local tkeys = {}
					for key in pairs(tblRIVol) do
						table.insert(tkeys, key)
					end

					table.sort(tkeys)

					print("after")
					for _, key in ipairs(tkeys) do 
						n=InsertRow(mainT,-1)
						SetCell(mainT,n,1,key)
						SetCell(mainT,n,2,string.format("%i",tblRIVol[key]))
					end
					
				end
			end
		end
	end
end

function round50txt6(n)
    x = (0.+n)/50. + 0.499
    y = math.floor(x)
    z = 0 + y
	return string.format("%06i",z*50)
end
