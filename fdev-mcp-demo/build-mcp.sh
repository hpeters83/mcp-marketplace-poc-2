FILE=test.flogo

rm -f $FILE

fdev cms simple_spec_path.json -f $FILE

# Build a flow with a prompt

PROMPT_FLOW=prompt_flow

fdev cf $PROMPT_FLOW -f $FILE
fdev cth $PROMPT_FLOW MCPTrigger --mcpHandlerType Prompt -f $FILE
fdev aa $PROMPT_FLOW set_prompt actreply -f $FILE
fdev sc flow $PROMPT_FLOW.data.metadata --jsonFile prompt-interface.json  -f $FILE
fdev sc activity $PROMPT_FLOW.set_prompt.input.reply.mapping.promptResult.messages[0].role user -f $FILE
fdev sc activity $PROMPT_FLOW.set_prompt.input.reply.mapping.promptResult.messages[0].content "Find the user with id 1234" -f $FILE
fdev sc activity $PROMPT_FLOW.set_prompt.schemas --jsonFile prompt-reply-interface.json -f $FILE

# fdev sc handler MCPTrigger.users_userId_GET.settings.handlerName getUserID -f $FILE

flogobuild build-exe -f $FILE

./test


#   "input": {
#     "reply": {
#       "mapping": {
#         "promptResult": {
#           "messages": [
#             {
#               "role": "user",
#               "content": "TEST"
#             }
#           ]
#         }
#       }
#     }
#   },

#   "schemas": {
#     "input": {
#       "reply": {
#         "type": "json",
#         "value": "{\"type\":\"object\",\"title\":\"Inputs\",\"properties\":{\"promptResult\":{\"type\":\"object\",\"properties\":{\"description\":{\"type\":\"string\"},\"messages\":{\"type\":\"array\",\"items\":{\"type\":\"object\",\"properties\":{\"role\":{\"type\":\"string\"},\"content\":{\"type\":\"string\"}},\"required\":[\"role\",\"content\"]}},\"success\":{\"type\":\"boolean\"},\"error\":{\"type\":\"string\"}}}},\"required\":[]}",
#         "fe_metadata": "{\"type\":\"object\",\"title\":\"Inputs\",\"properties\":{\"promptResult\":{\"type\":\"object\",\"properties\":{\"description\":{\"type\":\"string\"},\"messages\":{\"type\":\"array\",\"items\":{\"type\":\"object\",\"properties\":{\"role\":{\"type\":\"string\"},\"content\":{\"type\":\"string\"}},\"required\":[\"role\",\"content\"]}},\"success\":{\"type\":\"boolean\"},\"error\":{\"type\":\"string\"}}}},\"required\":[]}"
#       }
#     }
#   },
