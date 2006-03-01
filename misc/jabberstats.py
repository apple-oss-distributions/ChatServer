#!/usr/bin/python

#NOTE: This file is checked into cvs://src.apple.com/iservers/Servers/jabberd1/misc/

import sys, getopt, re, zlib, gzip, time, string, math, cgi, commands



def usage ():
	print "jabberstats [-v][-h] [logFiles]"
	sys.exit(0)
	
	
# Log entries look like this:
# Jan 23 11:55:53 ichatserver iChatServer-jabberd[495]: 20050123T19:55:53: [record] (rballard@ichatserver.apple.com): session end 2492 12 40 Vespertine
#return logEntry contains "jabberd[" and "session end"


def niceNum(inNum, precision, condense=0, KiloIsOneThousand=0):
#NOTE: precision doesn't seem to be working

	"""Returns a string representation for a floating point number
	that is rounded to the given precision and displayed with
	commas and spaces.  Optionall can condense the number to KB, MB, etc"""
	suffix = ""
	
	if condense and (inNum > 99999.0):  #only condense numbers less than 99,000
		suffixes = ["K", "M", "G", "T", "P"]
		KB = 1024.0
		if KiloIsOneThousand:
			KB = 1000.0
		while inNum > KB:
			inNum = inNum / KB
			suffix = suffixes.pop(0)

	accpow = math.floor(math.log10(precision))
	if inNum < 0:
		digits = int(math.fabs(inNum/pow(10,accpow)-0.5))
	else:
		digits = int(math.fabs(inNum/pow(10,accpow)+0.5))
	result = ''
	if digits > 0:
		for i in range(0,int(accpow)):
			if (i % 3)==0 and i>0:
				result = '0,' + result
			else:
				result = '0' + result
		curpow = int(accpow)
		while digits > 0:
			adigit = chr((digits % 10) + ord('0'))
			if (curpow % 3)==0 and curpow!=0 and len(result)>0:
				if curpow < 0:
					result = adigit + ' ' + result
				else:
					result = adigit + ',' + result
			elif curpow==0 and len(result)>0:
				result = adigit + '.' + result
			else:
				result = adigit + result
			digits = digits/10
			curpow = curpow + 1
		for i in range(curpow,0):
			if (i % 3)==0 and i!=0:
				result = '0 ' + result
			else:	
				result = '0' + result
		if curpow <= 0:
			result = "0." + result
		if inNum < 0:
			result = '-' + result
		if condense:
			result = result + suffix
	else:
		result = "0"
	return result


def isjabberLogout(logEntry):
		return re.search('jabberd\[.+session end', logEntry)

def sortedDictValues(adict):
	keys = adict.keys()
	keys.sort()
	keys.reverse()
	return [keys, map(adict.get, keys)]

def printJabberStats():
	global _verbose
	global _logfiles
	daysDict  = {}

	monthsDict = {}
	monthsDict['Jan'] = '01'
	monthsDict['Feb'] = '02'
	monthsDict['Mar'] = '03'
	monthsDict['Apr'] = '04'
	monthsDict['May'] = '05'
	monthsDict['Jun'] = '06'
	monthsDict['Jul'] = '07'
	monthsDict['Aug'] = '08'
	monthsDict['Sep'] = '09'
	monthsDict['Oct'] = '10'
	monthsDict['Nov'] = '11'
	monthsDict['Dec'] = '12'

	for aFilePath in _logfiles:
		if _verbose: print "attempting to unzip file: ", aFilePath
		f = gzip.open(aFilePath, 'r')
	
		try:
			lines = f.readlines()
			if _verbose: print "unzipped file: ", aFilePath
		except IOError:
			f = open(aFilePath, 'r')
			if _verbose: print "reading non-zip file: ", aFilePath
			lines = f.readlines()


		lines =	 filter(isjabberLogout, lines)

		for l in lines:
			elements = l.split()

			#Use MONTH+DAY as a key
			k = "".join([monthsDict[elements[0]], '.', string.zfill(elements[1],2) ])

			#Create a new dictionary item with key k if it doesn't already exist
			try:
					foo = daysDict[k]
			except:
				if _verbose: print "creating new key", k
				daysDict[k] = [0,0,0,0]
	
			# sum up the values for this "day"
			daysDict[k][0] =  daysDict[k][0] + int(elements[10])
			daysDict[k][1] =  daysDict[k][1] + int(elements[11])
			daysDict[k][2] =  daysDict[k][2] + int(elements[12])
			daysDict[k][3] =  daysDict[k][3] + 1

	#convert the dict to array sorted by key.  Ex:	[['Jan10', 'Jan19', 'Jan23'], [[2492, 12, 40], [2492, 12, 40], [8143, 30, 98]]]
	daysAndValues = sortedDictValues(daysDict)
	totBytes, totSent, totRcvd, totLogOuts = [0, 0, 0, 0]


	for day in daysAndValues[0]:
		totBytes = totBytes+daysDict[day][0]
		totSent = totSent+daysDict[day][1]
		totRcvd = totRcvd+daysDict[day][2]
		totLogOuts = totLogOuts+daysDict[day][3]

	mask = "%15s		%15s		%15s		%15s		%15s"

	print
	print mask % ("Date","Sessions","Bytes","Msgs Sent","Msgs Recvd")
	print mask % ("-----","-----","-----","-----","-----")

	print mask % ("Total", niceNum(totLogOuts,1), niceNum(totBytes,1,1)+"B", niceNum(totSent,1,1), niceNum(totRcvd,1,1))

	print mask % ("Average", niceNum(totLogOuts/len(daysAndValues[0]),1), niceNum(totBytes/len(daysAndValues[0]),1,1)+"B", niceNum(totSent/len(daysAndValues[0]),1,1), niceNum(totRcvd/len(daysAndValues[0]),1,1))

	print
	print "<b>Daily Statistics</b>"

	print mask % ("-----","-----","-----","-----","-----")
	for day in daysAndValues[0]:
		print mask % (day, niceNum(daysDict[day][3],1,1) , niceNum(daysDict[day][0],1,1)+"B", niceNum(daysDict[day][1],1,1), niceNum(daysDict[day][2],1,1))


def main(argv):
	global _verbose
	global _logfiles
	_verbose = 0
	_logfiles = ["/var/log/system.log"]

	try:
			opts, args = getopt.getopt(sys.argv[1:], 'hv', ['--help'])
	except getopt.GetoptError:
			usage()
			sys.exit(2)

	for opt, arg in opts:
		if opt in ("-h", "--help"):
			usage()
			sys.exit()
		elif opt == '-v':
			print "Verbose Mode"
			_verbose = 1

	if _verbose: print "opts= ", opts
	if _verbose: print "args = ", args

	if len(args) > 1:
		_logfiles = args

	if _verbose: print "_logfiles = ", _logfiles 

	print "Content-Type: text/html"		# HTML is following
	print								# blank line, end of headers

	print '<html><head>'
	print '<title>ichatserver.apple.com Stats</title>'
	print '</head><body>'

	print "<pre>"
	
	print "\n<b>Current connections: %s</b>" % commands.getoutput("netstat -n").count("5223");
	
	print "\n<b>uptime</b>"
	print commands.getoutput("uptime")
	
	print "\n<b>Process Info</b>"
	print commands.getoutput("ps -U jabber -o %cpu,%mem,start,rss,rssize,vsize,stat,cputime,command")

	printJabberStats()
	print "</pre>";
	print '</body></html>'


main(sys.argv)

