module("L_EnergeniePMS1", package.seeall)

local POLLING_INTERVAL = 30
local DEBUG_MODE = false
local PV = "0.5" -- plugin version number
local url = require("socket.url")
local socket = require("socket")
local http = require("socket.http")
local ltn12 = require("ltn12")
local ipAddress
		
local function log(text, level)
	luup.log("EnergeniePMS: " .. text, (level or 1))
	end

local function debug(text)
	if (DEBUG_MODE == true) or (DEBUG_MODE == "true")then
		log("debug: " .. text, 50)
	end
end

function EnergeniePMSLogin(ipAddress, lul_device)
	log("Logging in to check socket states")
	local postBody = "server=EG Web&pw=1"
	local controlURL = "http://" .. ipAddress .. "/login.html"
	debug("URL called = " ..controlURL)
	http.TIMEOUT = 5 -- 5 Second timeout
	local resultTable = {}
	local status, statusMsg = http.request{
		url = controlURL,
		sink = ltn12.sink.table(resultTable),
		method = "POST",
		headers = {
				["Accept"] = "*/*",
				["Content-Type"] = "application/x-www-form-urlencoded",
				["Content-Length"] = postBody:len()
					},
		source = ltn12.source.string(postBody),
											}
	debug("Login Status Message = " .. tostring(statusMsg))
	local EnergeniePMSResponse = table.concat( resultTable, "" )
	debug("Response received " .. EnergeniePMSResponse)
	if (EnergeniePMSResponse) then
		local socket1, socket2, socket3, socket4 = EnergeniePMSResponse:match("<script>var sockstates = %[(%d),(%d),(%d),(%d)%];var mac=")
			log("Socket state = [" ..socket1.. " , " ..socket2.. " , " ..socket3.. " , " ..socket4.. "]")
		local EnergeniePMSStatusTable = {
			cte1 = socket1,cte2 = socket2,cte3 = socket3,cte4 = socket4}
		for k, v in pairs(EnergeniePMSStatusTable) do
			luup.variable_set("urn:nodecentral-net:serviceId:EnergeniePMS1", k, v, lul_device)
		end
		debug("Logged In: Response returned processed")
		return "Logged In"
	else
		log("Error logging in: Empty response returned")
		return "Error logging in"
	end
end

function EnergeniePMSResponceProcessor(responseBody, command, page, lul_device)
	debug("Processing response = " .. responseBody)
	local loggedout = responseBody:match("<script>function PreSubmit()")
	local loggedin = responseBody:match("<script>var sockstates")
		if loggedout == nil then 
			debug("You are logged in, process request")
			local socket1, socket2, socket3, socket4 = responseBody:match("<script>var sockstates = %[(%d),(%d),(%d),(%d)%];var mac=")
			log("Socket state = [" ..socket1.. " , " ..socket2.. " , " ..socket3.. " , " ..socket4.. "]")
			local EnergeniePMSStatusTable = {
				cte1 = socket1,cte2 = socket2,cte3 = socket3,cte4 = socket4}
			for k, v in pairs(EnergeniePMSStatusTable) do
				luup.variable_set("urn:nodecentral-net:serviceId:EnergeniePMS1", k, v, lul_device)
			end
		else 
			debug("You are logged out, you need to log back in again")
			ipAddress = luup.devices[lul_device].ip
			debug("ipAddress = " ..ipAddress)
			debug("login and resend command = " ..command)
			if EnergeniePMSLogin(ipAddress, lul_device) == "Logged In" then
				EnergeniePMSCommand(command, "status.html", lul_device)
			else log("XXX HELP HUSTON WE HAVE A PROBLEM XXX")
			end
		end
end

function EnergeniePMSCommand(Erequest, page, lul_device)
	log("Command Sent ...")
	local postBody = Erequest
	debug("postBody = " ..Erequest)
	local controlURL = "http://" .. ipAddress .. "/" ..page
	debug("controlURL = " ..controlURL)
	http.TIMEOUT = 5 -- 5 Second timeout
	local resultTable = {}
	local status, statusMsg = http.request{
		url = controlURL,
		sink = ltn12.sink.table(resultTable),
		method = "POST",
		headers = {
				["Accept"] = "*/*",
				["Content-Type"] = "application/x-www-form-urlencoded",
				["Content-Length"] = postBody:len()
					},
		source = ltn12.source.string(postBody),
											}
	debug("EnergeniePMSCommand Response = " .. tostring(statusMsg))
	local responseBody = table.concat( resultTable, "" )
		if (responseBody) then
			log("SUCCESS: Response received ")
			EnergeniePMSResponceProcessor(responseBody,Erequest, page, lul_device )
		else
			log("ERROR: Empty response returned")
		end
end

function OnOffCall(lul_device, action, settings)
	log("OnOffCall function requested")
	debug("Action = " ..action.. " for deviceNo = " ..lul_device)
	local currentState = luup.variable_get("urn:nodecentral-net:serviceId:EnergeniePMS1", action, lul_device)
	local desiredState
		if currentState == "0" then desiredState = "1"
		elseif currentState == "1" then desiredState = "0" 
		end
	log("Current [" ..currentState .. "] - Desired [" ..desiredState.. "]")
	log("Command = " ..action .. "=" .. desiredState)
	local postBody = action .. "=" .. desiredState
	EnergeniePMSCommand(postBody, "status.html", lul_device)
end


local function checkEnergeniePMSSetUp(lul_device)
	debug("Checking device is configured correctly...")
	debugState = luup.variable_get("urn:nodecentral-net:serviceId:EnergeniePMS1", "Debug", lul_device)
	log("DEBUG Variable is set to : " .. tostring(debugState))
	ipAddress = luup.devices[lul_device].ip -- check if an ip address assigned 
	if ipAddress == nil or ipAddress == "" then -- if not stop and present error message
		luup.task('ERROR: IP Address is missing',2,'EnergeniePMS',-1)
		log("ERROR: IP Address missing " ..ipAddress.. " unable to progress")
		luup.variable_set("urn:nodecentral-net:serviceId:EnergeniePMS1", "Icon", 2, lul_device)
		luup.set_failure(1,lul_device) --it's failing
	else -- if IP is provided, present success message
		luup.task('IP Address for EnergeniePMS present, setup continues',4,'EnergeniePMS',-1)
		log("SUCCESS: IP Address present " ..ipAddress.. " for #" .. lul_device )
		luup.set_failure(0,lul_device) --its working
		luup.variable_set("urn:nodecentral-net:serviceId:EnergeniePMS1", "Icon", 1, lul_device)
		luup.variable_set("urn:nodecentral-net:serviceId:EnergeniePMS1", "LastUpdate", os.time(), lul_device)
		EnergeniePMSLogin(ipAddress, lul_device)
	end 
end
			
-- Initialize plug-in
function EnergeniePMSStartup(lul_device)
	-- set attributes for parent device
	log("Start up, Creating device..." ..lul_device)
	--luup.attr_set( "category_num", "3", lul_device)
	--luup.attr_set( "subcategory_num", "1", lul_device)
	luup.variable_set("urn:nodecentral-net:serviceId:EnergeniePMS1", "PluginVersion", PV, lul_device)
	local debugState = luup.variable_get("urn:nodecentral-net:serviceId:EnergeniePMS1", "Debug", lul_device)
	if debugState == nil or "" then 
		luup.variable_set("urn:nodecentral-net:serviceId:EnergeniePMS1", "Debug", false, lul_device)
	end
		
	log("DEBUG MODE is set to : " .. tostring(DEBUG_MODE))
	debug("Start up, Device created, now check configuration")
	checkEnergeniePMSSetUp(lul_device)
end