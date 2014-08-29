import fileinput
import re
import collections
import os
import sys
import hubs

def setupVariables(mappings, hubsArray):
	global variables
	variables['NFD1_IP'] = hubs.getIp(hubsArray, mappings['NFD1'])
	variables['NFD1_PREFIX'] = hubs.getPrefix(hubsArray, variables['NFD1_IP'])
	variables['NFD2_IP'] = hubs.getIp(hubsArray, mappings['NFD2'])
	variables['NFD2_PREFIX'] = hubs.getPrefix(hubsArray, variables['NFD2_IP'])	
	variables['NFD3_IP'] = hubs.getIp(hubsArray, mappings['NFD3'])
	variables['NFD3_PREFIX'] = hubs.getPrefix(hubsArray, variables['NFD3_IP'])
	variables['PROD_NFD1_IP'] = mappings['PRODUCER_NFD1']
	variables['PROD_NFD21_IP'] = mappings['PRODUCER1_NFD2']
	variables['PROD_NFD22_IP'] = mappings['PRODUCER2_NFD2']
	variables['PROD_NFD31_IP'] = mappings['DEMO1']
	variables['PROD_NFD32_IP'] = mappings['DEMO2']
	return variables

# sets variables from variables dictionary in file named fileName
# varRegexString represents regular expression for retrieveing 
# variables and their corresponding values from configuration file
# varRegexString should contain groups named 'variable' and 'value',
# for instance:
# 	'(?P<variable>[A-Z0-9_]+)=\"(?P<value>[A-z0-9-+/.]+)\"'
#
# corresponds to variables only in capitals and with underscores which
# has string values (inside double quotes - "). 
#
# hubsArray is used when variable value (ip address) can be found 
# in hubs.txt and comment is printed next to the new value with 
# the human-readable hub name (like 'ndn.caida', etc.)
# ending is used to append after the variable value (for instance ';')
def setVars(variables, fileName, varRegexString, hubsArray, ending):
	lines = []
	with open(fileName) as f:
		for line in f:
			found = False
			strippedLine = line.strip()
			if len(strippedLine) > 0 and strippedLine[0] != '#':
				pattern = re.compile(varRegexString)
				m = pattern.match(strippedLine)
				if m:
					varName = m.group('variable')
					varValue = m.group('value')
					if variables.has_key(varName):
						newLine = str(varName)+"=\""+variables[varName]+"\""+ending
						
						hubName = hubs.getName(hubsArray, variables[varName])
						if hubName != '':
							newLine = newLine + " # "+hubName
						newLine = newLine + '\n'

						lines.append(newLine)
						found = True
			if not found:
				lines.append(line)
	f = open(fileName, "w")
	for line in lines:
		f.write(line)
	f.close()

def setVarsBash(variables, bashScript, hubsArray):
	regexString = '(?P<variable>[A-Z0-9_]+)=\"(?P<value>[A-z0-9-+/.]+)\"'
	setVars(variables, bashScript, regexString, hubsArray, '')

def updateCfg(variables, cfgFile, hubsArray):
	regexString = '(?P<variable>[a-z_]+)\s*=\s*\"(?P<value>[A-z0-9-+/.]+)\";'
	setVars(variables, cfgFile, regexString, hubsArray, ';')

def readMappings(mappings_file):
  mappings = {}
  lineno = 0
  with open(mappings_file) as f:
  	for line in f:
  		lineno = lineno+1
  		line = line.strip()
  		if len(line) > 0 and line[0] != '#':
  			pattern = re.compile('(?P<node>NFD1|NFD2|NFD3|DEMO1|DEMO2|PRODUCER_NFD1|PRODUCER1_NFD2|PRODUCER2_NFD2)\s+(?P<name>[A-z0-9.]+)')
  			m = pattern.match(line)
  			if m:
  				node = m.group('node')
  				name = m.group('name')
  				if mappings.has_key(node):
  					print "mapping conflict on line " + str(lineno) + ". aborting"
  					exit(1)
  				else:
  					mappings[node] = name
  return mappings

# *****************************************************************************
if __name__ == '__main__':
	if len(sys.argv) < 2:
	  print "usage: "+__file__+" <mappings_file> <hubs_file>"
	  exit(1)

	mappings_file = sys.argv[1]
	hubsfile = sys.argv[2]

	mappings = readMappings(mappings_file)
	hubsArray = hubs.readHubs(hubsfile)

	# setup variables dictionary
	# key corresponds to the variable name in setup-nfd.sh
	# value defines variable's value
	variables = {
		'NFD1_IP':None,
		'NFD1_PREFIX':None,
		'NFD2_IP':None,
		'NFD2_PREFIX':None,
		'NFD3_IP':None,
		'NFD3_PREFIX':None,
		'PROD_NFD1_IP':None,
		'PROD_NFD21_IP':None,
		'PROD_NFD22_IP':None,
		'PROD_NFD31_IP':None,
		'PROD_NFD32_IP':None
	}
	variables = setupVariables(mappings, hubsArray)
	
	# set variables in setup-nfd.sh from mappings
	setVarsBash(variables, "setup-nfd.sh", hubsArray)

	# set prefixes in configuration files
	cfgFile = 'producer-ndncomm/ndnrtc.cfg'
	variables['ndn_prefix']=variables['NFD1_PREFIX']
	updateCfg(variables, cfgFile, hubsArray)

	cfgFile = 'producer-remap1/ndnrtc.cfg'
	variables['ndn_prefix']=variables['NFD2_PREFIX']
	updateCfg(variables, cfgFile, hubsArray)

	cfgFile = 'producer-remap2/ndnrtc.cfg'
	variables['ndn_prefix']=variables['NFD2_PREFIX']
	updateCfg(variables, cfgFile, hubsArray)

	cfgFile = 'producer-demo1/ndnrtc.cfg'
	variables['ndn_prefix']=variables['NFD3_PREFIX']
	updateCfg(variables, cfgFile, hubsArray)

	cfgFile = 'producer-demo2/ndnrtc.cfg'
	variables['ndn_prefix']=variables['NFD3_PREFIX']
	updateCfg(variables, cfgFile, hubsArray)