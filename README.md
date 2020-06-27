# bedrock_namespace_launcher
Script to launch BDS in its own network namespace, allowing multiple bedrock servers on a single machine.

The easiest way to achieve this is to make multiple copies of the bedrock server folder and put a copy of this script in each one. YOU MUST CUSTOMIZE THE SERVER NUMBER OF EACH COPY BEFORE YOU LAUNCH THEM. Just set the NUMBER variable in the scripts to different numbers: 1, 2, 3, etc.

Usage: $ ./netns_bds_1.sh
