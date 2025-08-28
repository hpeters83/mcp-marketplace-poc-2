set -e

echo "you passed me $*"
echo "you passed me $@"

echo $1
cd $1
ls

# TODO: Pass this in as argument
source token.sh

echo "MCP SEVER NAME: $2"

# FILE="TestMCP.flogo"
# FILE="TestMCP.json"
# FILE="Customer_MCP_Client.flogo"
FILE="Platform_MCP_Server.flogo"
# SPEC_FILE="simple_spec.json"
SPEC_FILE="control-plane-api-1.9.json"
# CustomerSwaggerClient.json
# SPEC_FILE="CustomerSwaggerClient.json"
# SPEC_FILE="simple_spec_path.json"

rm -f $FILE

# Platform
MCP_PORT=3050
# Get User
# MCP_PORT=3045

fdev cms $SPEC_FILE --token $platform_token -f $FILE
# fdev cms $SPEC_FILE -f $FILE
# fdev cms control-plane-api-1.9.json -f MCP_Platform.flogo
# fdev sc trigger "MCPTrigger.settings.serverPort" 3045 -f $FILE
# Set the MCP Port
# fdev sc property MCP_Port 3045 -f $FILE

fdev sc property MCP_Port $MCP_PORT -f $FILE


# Set the Enpoint
# fdev sc property API_Endpoint "http://localhost:9999" -f $FILE
fdev sc property API_Endpoint "https://tibcopm.us-west.my.tibco.com" -f $FILE
# fdev cap API_Endpoint string "https://tibcopm.us-west.my.tibco.com" -f $FILE


# Add this for deployment
fdev sc any metadata.endpoints --jsonValue "[{\"protocol\": \"http\",\"port\": \"$MCP_PORT\",\"title\": \"MCPTrigger\",\"type\": \"public\"}]" -f $FILE

PROMPT_FLOW=prompt_flow

fdev cf $PROMPT_FLOW -f $FILE
fdev cth $PROMPT_FLOW MCPTrigger --mcpHandlerType Prompt --mcpHandlerName 'UserFinder' --mcpHandlerDescription 'Find your user' -f $FILE
fdev aa $PROMPT_FLOW set_prompt actreply -f $FILE
fdev sc flow $PROMPT_FLOW.data.metadata --jsonFile prompt-interface.json  -f $FILE
fdev sc activity $PROMPT_FLOW.set_prompt.input.reply.mapping.promptResult.messages[0].role user -f $FILE
fdev sc activity $PROMPT_FLOW.set_prompt.input.reply.mapping.promptResult.messages[0].content "Find the user with id 1234" -f $FILE
fdev sc activity $PROMPT_FLOW.set_prompt.schemas --jsonFile prompt-reply-interface.json -f $FILE


flogobuild build-exe -f $FILE

# flogobuild build-tp-deployment -f $FILE -o ./flogo-mcp-server.zip
flogobuild build-tp-deployment -f $FILE -o ./

# ./TestMCP
