####HighendUserCreationScript.ps1####

How to use:

1. Enter TLA in line 14 and HUB in line 17.

	- If TLA = HUB, use line 14; place "#" in front of line 17 to "comment" out line 17.

2. Enter address information in lines 20-24.

3. Update OU Path (line 26).

	- If TLA != HUB, use line 27; place "#" in front of line 28 to "comment" out line 28.

	- If TLA = HUB, use line 28; place "#" in front of line 27 to "comment" out line 27
		- For example, locations like LAK, SYR, HAR, etc.

5. Save. 

6. Run script and follow the prompt. 
	
	- If the user did not exist already, the script will give you an error. Do not be scared. Ignore this and continue on with the script. 

7. Once the script finishes running, open AD and verify information.

	- If the user did not exist prior to running the script, please enter in the manager information. 

8. Verify all the information in AD is correct. 


NOTE!!!
 
- This script does not update the manager name. Please update info as needed. 


