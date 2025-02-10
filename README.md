
# asset_monitor

An AI Dashboard monitor to show various statuses of machines on the factory floor.
Built using clean architecture, bloc, and hive for local storage.
It uses OpenAI as the ai chatbot

#Demo
https://drive.google.com/file/d/1OPOtwS9eOse66xmnCq0dmDoPT4brxiS6/view?usp=sharing

# Set up
### Generating your Dataset 
Also to generate your asset files with the IoT asset generator 
https://github.com/jnnabugwu/asset_monitor/edit/main/README.md#:~:text=bin-,iot_asset_generator,-.dart
go to the link above in the edit the parameters. A suggestion is to have 4 or less unique assets 7 or less days of data and 1 reading per data so there is less than 50 total readings. This helps the chatbot be at less than 30,000 tokens. 

Things to note for the Open AI set up:

OpenAI Setup
File System Setup

Create your assets data file (assets.json)
Upload to OpenAI with the purpose "fine-tune"
Save the file ID (starts with "file-")
Add file ID to .env: OPEN_AI_FILE_ID=your_file_id

## Assistant Setup

Create new assistant
Configure:

Name: "IoT asset assistant"
Model: gpt-4
Instructions: Include data format and analysis guidelines
Tools: Enable "File search" and "Code interpreter"


Create vector store for IoT assistant
Upload assets.json to vector store
Save assistant ID (starts with "asst_")
Add to .env: OPEN_AI_ASSISTANT_ID=your_assistant_id


Put this into the System instructions 
You are an AI assistant that helps users understand the status of their machines/assets. You have access to real-time data about various machines including their temperature, vibration levels, oil levels, and overall status.

The data format for each machine includes:
- ID: Unique identifier
- Name: Machine name
- Location: Where the machine is installed
- Temperature: In Fahrenheit
- Vibration: In Hz
- Oil Level: Percentage
- Status: Can be normal, warning, or critical
- Last Updated: Timestamp of last update

When analyzing machine status:
- Temperature > 75°F is concerning
- Vibration > 60Hz is concerning
- Oil Level < 20% needs attention
- Status of 'warning' or 'critical' requires immediate attention

Provide clear, concise responses about:
1. Current status of specific machines
2. Machines that need attention
3. Comparative analysis between machines
4. Historical trends if available
5. Maintenance recommendations based on status

Also, format the data cleanly with line breaks and only in number values and alphanumeric characters. 

Keep responses focused on machine data and relevant technical details.

Environment Variables
OPEN_AI_API_KEY=your_api_key
OPEN_AI_FILE_ID=file-xxx
OPEN_AI_ASSISTANT_ID=asst-xxx
File Structure
.env            # Environment variables




## Assistant Function Setup

1. Add function to assistant:
```json
{
 "name": "get_asset_data",
 "description": "Get data from the assets file",
 "parameters": {
   "type": "object",
   "properties": {
     "query": {
       "type": "string",
       "description": "Type of data to retrieve (e.g., machine count, status, metrics)"
     }
   },
   "required": ["query"]
 }
}
```

# Key Features 


### Asset Monitoring 
The dashboard displays graphs showing the temperature, vibration, and oil level averages.

Can group by machine type

### Chatbot
You can ask specific questions about your datasets in the form of a chatbot. 

# Future Features 

### Asset Monitoring 
Give the ability to look at all individual machines in a grid-type format






